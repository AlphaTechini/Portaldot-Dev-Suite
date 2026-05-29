#![cfg_attr(not(feature = "std"), no_std)]

#[ink::contract]
mod escrow {
    #[ink(storage)]
    pub struct Escrow {
        buyer: AccountId,
        seller: AccountId,
        arbiter: AccountId,
        amount: Balance,
        state: EscrowState,
    }

    #[ink::scale_derive(Encode, Decode, TypeInfo)]
    #[derive(PartialEq, Eq)]
    pub enum EscrowState {
        AwaitingPayment,
        AwaitingApproval,
        Completed,
        Refunded,
        Disputed,
    }

    impl Escrow {
        #[ink(constructor)]
        pub fn new(seller: AccountId, arbiter: AccountId) -> Self {
            Self {
                buyer: Self::env().caller(),
                seller,
                arbiter,
                amount: 0,
                state: EscrowState::AwaitingPayment,
            }
        }

        #[ink(message, payable)]
        pub fn deposit(&mut self) {
            assert_eq!(self.state, EscrowState::AwaitingPayment);
            let transferred = self.env().transferred_value();
            assert!(transferred > 0);
            self.amount = transferred;
            self.state = EscrowState::AwaitingApproval;
            self.env().emit_event(Funded {
                buyer: self.buyer,
                amount: transferred,
            });
        }

        #[ink(message)]
        pub fn approve(&mut self) {
            assert_eq!(self.state, EscrowState::AwaitingApproval);
            assert_eq!(self.env().caller(), self.buyer);
            self.state = EscrowState::Completed;
            self.env().emit_event(Approved {
                buyer: self.buyer,
                seller: self.seller,
                amount: self.amount,
            });

            let _ = self.env().transfer(self.seller, self.amount);
        }

        #[ink(message)]
        pub fn refund(&mut self) {
            assert_eq!(self.state, EscrowState::AwaitingApproval);
            assert_eq!(self.env().caller(), self.arbiter);
            self.state = EscrowState::Refunded;
            self.env().emit_event(Refunded {
                buyer: self.buyer,
                amount: self.amount,
            });

            let _ = self.env().transfer(self.buyer, self.amount);
        }

        #[ink(message)]
        pub fn dispute(&mut self) {
            assert_eq!(self.state, EscrowState::AwaitingApproval);
            let caller = self.env().caller();
            assert!(caller == self.buyer || caller == self.seller);
            self.state = EscrowState::Disputed;
            self.env().emit_event(Disputed {
                by: caller,
                amount: self.amount,
            });
        }

        #[ink(message)]
        pub fn resolve_dispute(&mut self, to_seller: bool) {
            assert_eq!(self.state, EscrowState::Disputed);
            assert_eq!(self.env().caller(), self.arbiter);

            if to_seller {
                self.state = EscrowState::Completed;
                let _ = self.env().transfer(self.seller, self.amount);
            } else {
                self.state = EscrowState::Refunded;
                let _ = self.env().transfer(self.buyer, self.amount);
            }
        }

        #[ink(message)]
        pub fn get_state(&self) -> EscrowState {
            self.state.clone()
        }

        #[ink(message)]
        pub fn get_amount(&self) -> Balance {
            self.amount
        }

        #[ink(message)]
        pub fn get_parties(&self) -> (AccountId, AccountId, AccountId) {
            (self.buyer, self.seller, self.arbiter)
        }
    }

    #[ink(event)]
    pub struct Funded {
        #[ink(topic)]
        pub buyer: AccountId,
        pub amount: Balance,
    }

    #[ink(event)]
    pub struct Approved {
        #[ink(topic)]
        pub buyer: AccountId,
        #[ink(topic)]
        pub seller: AccountId,
        pub amount: Balance,
    }

    #[ink(event)]
    pub struct Refunded {
        #[ink(topic)]
        pub buyer: AccountId,
        pub amount: Balance,
    }

    #[ink(event)]
    pub struct Disputed {
        #[ink(topic)]
        pub by: AccountId,
        pub amount: Balance,
    }
}
