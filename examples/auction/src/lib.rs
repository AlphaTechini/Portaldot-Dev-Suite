#![cfg_attr(not(feature = "std"), no_std)]

#[ink::contract]
mod auction {
    use ink::storage::Mapping;

    #[ink(storage)]
    pub struct Auction {
        required_participants: u32,
        bidders: Mapping<AccountId, Balance>,
        bidder_count: u32,
        highest_bidder: Option<AccountId>,
        highest_bid: Balance,
        total_pot: Balance,
        ended: bool,
    }

    #[ink(event)]
    pub struct Bid {
        #[ink(topic)]
        bidder: AccountId,
        amount: Balance,
    }

    #[ink(event)]
    pub struct AuctionEnded {
        #[ink(topic)]
        winner: AccountId,
        total_amount: Balance,
    }

    impl Auction {
        #[ink(constructor)]
        pub fn new(required_participants: u32) -> Self {
            assert!(required_participants > 0);
            Self {
                required_participants,
                bidders: Mapping::default(),
                bidder_count: 0,
                highest_bidder: None,
                highest_bid: 0,
                total_pot: 0,
                ended: false,
            }
        }

        #[ink(message, payable)]
        pub fn bid(&mut self) {
            assert!(!self.ended, "Auction already ended");
            
            let caller = self.env().caller();
            assert!(self.bidders.get(caller).is_none(), "Already bid");
            
            let amount = self.env().transferred_value();
            assert!(amount > 0, "Bid must be greater than 0");

            self.bidders.insert(caller, &amount);
            self.bidder_count += 1;
            self.total_pot += amount;

            if amount > self.highest_bid {
                self.highest_bid = amount;
                self.highest_bidder = Some(caller);
            }

            self.env().emit_event(Bid { bidder: caller, amount });

            if self.bidder_count >= self.required_participants {
                self.end_auction();
            }
        }

        fn end_auction(&mut self) {
            self.ended = true;
            let winner = self.highest_bidder.expect("Must have a winner");
            self.env().emit_event(AuctionEnded {
                winner,
                total_amount: self.total_pot,
            });
        }

        #[ink(message)]
        pub fn get_winner(&self) -> Option<AccountId> {
            self.highest_bidder
        }

        #[ink(message)]
        pub fn get_total_pot(&self) -> Balance {
            self.total_pot
        }

        #[ink(message)]
        pub fn is_ended(&self) -> bool {
            self.ended
        }

        #[ink(message)]
        pub fn get_bidder_count(&self) -> u32 {
            self.bidder_count
        }
    }
}
