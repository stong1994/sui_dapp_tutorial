#[test_only]
module sui_dapp_tutorial::my_object_tests {
    use sui::test_scenario::{Self as ts, Scenario};
    use sui_dapp_tutorial::my_object::{Self, MyObject};
    use sui::test_utils::assert_eq;
    
    // 测试场景中使用的地址常量
    const ADMIN: address = @0xAD;
    const USER: address = @0xB0B;
    
    // 辅助函数：创建基础测试场景
    fun setup_test(): Scenario {
        ts::begin(ADMIN)
    }
    
    #[test]
    fun test_create_object() {
        let scenario = setup_test();
        let test = &mut scenario;
        
        // 第一步：创建对象
        ts::next_tx(test, ADMIN);
        {
            my_object::create_object(100, ts::ctx(test));
        };
        
        // 第二步：验证对象创建成功
        ts::next_tx(test, ADMIN);
        {
            let object = ts::take_from_sender<MyObject>(test);
            assert_eq(my_object::get_value(&object), 100);
            assert_eq(my_object::get_owner(&object), ADMIN);
            ts::return_to_sender(test, object);
        };
        
        // 第三步：测试更新值
        ts::next_tx(test, ADMIN);
        {
            let object = ts::take_from_sender<MyObject>(test);
            my_object::update_value(&mut object, 200, ts::ctx(test));
            assert_eq(my_object::get_value(&object), 200);
            ts::return_to_sender(test, object);
        };
        
        ts::end(scenario);
    }
    
    #[test]
    #[expected_failure(abort_code = my_object::ERROR_UNAUTHORIZED)]
    fun test_unauthorized_update() {
        let scenario = setup_test();
        let test = &mut scenario;
        
        // 第一步：ADMIN创建对象
        ts::next_tx(test, ADMIN);
        {
            my_object::create_object(100, ts::ctx(test));
        };
        
        // 第二步：USER尝试更新对象（应该失败）
        ts::next_tx(test, USER);
        {
            let object = ts::take_from_address<MyObject>(test, ADMIN);
            my_object::update_value(&mut object, 200, ts::ctx(test));
            ts::return_to_address(ADMIN, object);
        };
        
        ts::end(scenario);
    }
}
