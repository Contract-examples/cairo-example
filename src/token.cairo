#[starknet::contract]
mod ERC20Token {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::contract_address;
    use starknet::storage::Map;

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
        allowances: Map<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256,
    }

    // internal functions
    #[generate_trait]
    impl InternalFunctions of InternalTrait {
        fn _transfer(
            ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) {
            assert(!sender.is_zero(), 'ERC20: transfer from 0');
            assert(!recipient.is_zero(), 'ERC20: transfer to 0');

            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);

            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }

        fn _approve(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            assert(!owner.is_zero(), 'ERC20: approve from 0');
            assert(!spender.is_zero(), 'ERC20: approve to 0');

            self.allowances.write((owner, spender), amount);

            self.emit(Approval { owner, spender, value: amount });
        }

        fn _spend_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            let current_allowance = self.allowances.read((owner, spender));
            let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;
            let is_unlimited_allowance = current_allowance.low == ONES_MASK
                && current_allowance.high == ONES_MASK;
            if !is_unlimited_allowance {
                self._approve(owner, spender, current_allowance - amount);
            }
        }
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name_: felt252,
        symbol_: felt252,
        decimals_: u8,
        initial_supply: u256,
        recipient: ContractAddress
    ) {
        self.name.write(name_);
        self.symbol.write(symbol_);
        self.decimals.write(decimals_);
        
        // mint to recipient
        assert(!recipient.is_zero(), 'ERC20: mint to 0');
        self.total_supply.write(initial_supply);
        self.balances.write(recipient, initial_supply);
        
        // emit Transfer event
        let zero_address = contract_address_const::<0>();
        self.emit(Transfer { from: zero_address, to: recipient, value: initial_supply });
    }

    #[external(v0)]
    fn name(self: @ContractState) -> felt252 {
        self.name.read()
    }

    #[external(v0)]
    fn symbol(self: @ContractState) -> felt252 {
        self.symbol.read()
    }

    #[external(v0)]
    fn decimals(self: @ContractState) -> u8 {
        self.decimals.read()
    }

    #[external(v0)]
    fn total_supply(self: @ContractState) -> u256 {
        self.total_supply.read()
    }

    #[external(v0)]
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        self.balances.read(account)
    }

    #[external(v0)]
    fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
        self.allowances.read((owner, spender))
    }

    #[external(v0)]
    fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
        let sender = get_caller_address();
        self._transfer(sender, recipient, amount);
        true
    }

    #[external(v0)]
    fn transfer_from(
        ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool {
        let caller = get_caller_address();
        self._spend_allowance(sender, caller, amount);
        self._transfer(sender, recipient, amount);
        true
    }

    #[external(v0)]
    fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
        let caller = get_caller_address();
        self._approve(caller, spender, amount);
        true
    }

    #[external(v0)]
    fn increase_allowance(ref self: ContractState, spender: ContractAddress, added_value: u256) -> bool {
        let caller = get_caller_address();
        self._approve(
            caller, 
            spender, 
            self.allowances.read((caller, spender)) + added_value
        );
        true
    }

    #[external(v0)]
    fn decrease_allowance(
        ref self: ContractState, spender: ContractAddress, subtracted_value: u256
    ) -> bool {
        let caller = get_caller_address();
        self._approve(
            caller, 
            spender, 
            self.allowances.read((caller, spender)) - subtracted_value
        );
        true
    }
} 