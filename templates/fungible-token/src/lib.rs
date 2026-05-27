#![cfg_attr(not(feature = "std"), no_std)]

use ink::prelude::string::String;

#[ink::contract]
mod fungible_token {
    use ink::storage::Mapping;

    #[ink(storage)]
    pub struct FungibleToken {
        total_supply: Balance,
        balances: Mapping<AccountId, Balance>,
        allowances: Mapping<(AccountId, AccountId), Balance>,
        decimals: u8,
        name: String,
        symbol: String,
    }

    impl FungibleToken {
        #[ink(constructor)]
        pub fn new(
            initial_supply: Balance,
            decimals: u8,
            name: String,
            symbol: String,
        ) -> Self {
            let caller = Self::env().caller();
            let mut balances = Mapping::default();
            balances.insert(caller, &initial_supply);

            Self {
                total_supply: initial_supply,
                balances,
                allowances: Mapping::default(),
                decimals,
                name,
                symbol,
            }
        }

        #[ink(message)]
        pub fn total_supply(&self) -> Balance {
            self.total_supply
        }

        #[ink(message)]
        pub fn balance_of(&self, owner: AccountId) -> Balance {
            self.balances.get(owner).unwrap_or_default()
        }

        #[ink(message)]
        pub fn transfer(&mut self, to: AccountId, value: Balance) -> bool {
            let from = self.env().caller();
            self.transfer_from_to(from, to, value)
        }

        #[ink(message)]
        pub fn approve(&mut self, spender: AccountId, value: Balance) -> bool {
            let owner = self.env().caller();
            self.allowances.insert((owner, spender), &value);
            self.env().emit_event(Approval {
                owner,
                spender,
                value,
            });
            true
        }

        #[ink(message)]
        pub fn transfer_from(
            &mut self,
            from: AccountId,
            to: AccountId,
            value: Balance,
        ) -> bool {
            let caller = self.env().caller();
            let allowance = self
                .allowances
                .get((from, caller))
                .unwrap_or_default();
            if allowance < value {
                return false;
            }
            self.allowances.insert((from, caller), &(allowance - value));
            self.transfer_from_to(from, to, value)
        }

        fn transfer_from_to(
            &mut self,
            from: AccountId,
            to: AccountId,
            value: Balance,
        ) -> bool {
            let from_balance = self.balances.get(from).unwrap_or_default();
            if from_balance < value {
                return false;
            }
            self.balances.insert(from, &(from_balance - value));
            let to_balance = self.balances.get(to).unwrap_or_default();
            self.balances.insert(to, &(to_balance + value));
            self.env().emit_event(Transfer {
                from: Some(from),
                to: Some(to),
                value,
            });
            true
        }
    }

    #[ink(event)]
    pub struct Transfer {
        #[ink(topic)]
        pub from: Option<AccountId>,
        #[ink(topic)]
        pub to: Option<AccountId>,
        pub value: Balance,
    }

    #[ink(event)]
    pub struct Approval {
        #[ink(topic)]
        pub owner: AccountId,
        #[ink(topic)]
        pub spender: AccountId,
        pub value: Balance,
    }
}
