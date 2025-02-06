#[test_only]
module sui_dapp_tutorial::my_object_tests {
    use sui::test_scenario::{Self as test, Scenario};
    use sui::transfer;
    use sui_dapp_tutorial::my_object::{Self, MyObject};

    const ADMIN: address = @0xAAAA;
    const USER: address = @0xBBBB;
    const INITIAL_VALUE: u64 = 42;
    const NEW_VALUE: u64 = 100;

    fun test_scenario(): Scenario {
        test::begin(ADMIN)
    }

    #[test]
    fun test_create_object() {
        let scenario = test_scenario();
        let test = &mut scenario;
        
        // 创建对象
        test::next_tx(test, ADMIN);
        {
            my_object::create_object(INITIAL_VALUE, test::ctx(test));
        };

        // 验证对象
        test::next_tx(test, ADMIN);
        {
            let object = test::take_from_sender<MyObject>(test);
            assert!(my_object::get_value(&object) == INITIAL_VALUE, 0);
            test::return_to_sender(test, object);
        };
        
        test::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = sui_dapp_tutorial::my_object::ERROR_NOT_OWNER)]
    fun test_unauthorized_update() {
        let scenario = test_scenario();
        let test = &mut scenario;
        
        // Admin 创建对象
        test::next_tx(test, ADMIN);
        {
            let object = my_object::create_object_for_testing(INITIAL_VALUE, test::ctx(test));
            transfer::public_transfer(object, ADMIN);
        };

        // User 尝试更新对象（应该失败）
        test::next_tx(test, USER);
        {
            let object = test::take_from_address<MyObject>(test, ADMIN);
            my_object::update_value(&mut object, NEW_VALUE, test::ctx(test));
            test::return_to_address(ADMIN, object);
        };
        
        test::end(scenario);
    }
}
