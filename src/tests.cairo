use starknet::ContractAddress;
use starknet::contract_address_const;
use starknet::testing::set_caller_address;
use token::token::ERC20Token;

// use Cairo testing trait
#[cfg(test)]
mod tests {
    use super::{ERC20Token, ContractAddress, contract_address_const, set_caller_address};

    fn setup() -> (ERC20Token::ContractState, ContractAddress) {
        // create test state
        let mut state = ERC20Token::contract_state_for_testing();
        let admin = contract_address_const::<1>();

        // call constructor
        ERC20Token::constructor(
            ref state,
            'MyToken',
            'MTK',
            18,
            1000_u256,
            admin
        );

        (state, admin)
    }

    #[test]
    fn test_name() {
        let (state, _) = setup();
        assert(ERC20Token::name(@state) == 'MyToken', 'Wrong name');
    }

    #[test]
    fn test_symbol() {
        let (state, _) = setup();
        assert(ERC20Token::symbol(@state) == 'MTK', 'Wrong symbol');
    }

    #[test]
    fn test_decimals() {
        let (state, _) = setup();
        assert(ERC20Token::decimals(@state) == 18, 'Wrong decimals');
    }

    #[test]
    fn test_total_supply() {
        let (state, _) = setup();
        assert(ERC20Token::total_supply(@state) == 1000_u256, 'Wrong supply');
    }

    #[test]
    fn test_balance_of() {
        let (state, admin) = setup();
        assert(ERC20Token::balance_of(@state, admin) == 1000_u256, 'Wrong balance');
    }

    #[test]
    fn test_transfer() {
        let (mut state, sender) = setup();
        let recipient = contract_address_const::<2>();
        
        // set sender as caller
        set_caller_address(sender);
        
        // execute transfer
        assert(ERC20Token::transfer(ref state, recipient, 200_u256), 'Transfer failed');
        
        // check balance change
        assert(ERC20Token::balance_of(@state, sender) == 800_u256, 'Sender balance wrong');
        assert(ERC20Token::balance_of(@state, recipient) == 200_u256, 'Recipient balance wrong');
    }

    #[test]
    fn test_approve_and_allowance() {
        let (mut state, owner) = setup();
        let spender = contract_address_const::<2>();
        
        // set owner as caller
        set_caller_address(owner);
        
        // approve
        assert(ERC20Token::approve(ref state, spender, 300_u256), 'Approve failed');
        
        // check allowance
        assert(ERC20Token::allowance(@state, owner, spender) == 300_u256, 'Allowance wrong');
        
        // test increase allowance
        assert(ERC20Token::increase_allowance(ref state, spender, 100_u256), 'Increase allowance failed');
        assert(ERC20Token::allowance(@state, owner, spender) == 400_u256, 'Increased allowance wrong');
        
        // test decrease allowance
        assert(ERC20Token::decrease_allowance(ref state, spender, 150_u256), 'Decrease allowance failed');
        assert(ERC20Token::allowance(@state, owner, spender) == 250_u256, 'Decreased allowance wrong');
    }

    #[test]
    fn test_transfer_from() {
        let (mut state, owner) = setup();
        let spender = contract_address_const::<2>();
        let recipient = contract_address_const::<3>();
        
        // set owner as caller and approve
        set_caller_address(owner);
        assert(ERC20Token::approve(ref state, spender, 500_u256), 'Approve failed');
        
        // set spender as caller and transfer from owner to recipient
        set_caller_address(spender);
        assert(ERC20Token::transfer_from(ref state, owner, recipient, 300_u256), 'Transfer from failed');
        
        // check balance and allowance
        assert(ERC20Token::balance_of(@state, owner) == 700_u256, 'Owner balance wrong');
        assert(ERC20Token::balance_of(@state, recipient) == 300_u256, 'Recipient balance wrong');
        assert(ERC20Token::allowance(@state, owner, spender) == 200_u256, 'Allowance wrong after transfer');
    }
} 