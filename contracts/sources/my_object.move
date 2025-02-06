module sui_dapp_tutorial::my_object {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // 错误码
    const ERROR_NOT_OWNER: u64 = 1;

    /// 主要的业务对象
    struct MyObject has key, store {
        id: UID,
        value: u64,
        owner: address
    }

    /// 创建新的对象
    public entry fun create_object(value: u64, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let object = MyObject {
            id: object::new(ctx),
            value,
            owner: sender
        };
        transfer::public_transfer(object, sender);
    }

    /// 更新对象的值
    public entry fun update_value(object: &mut MyObject, new_value: u64, ctx: &TxContext) {
        // 检查调用者是否为对象所有者
        assert!(tx_context::sender(ctx) == object.owner, ERROR_NOT_OWNER);
        object.value = new_value;
    }

    /// 获取对象的值
    public fun get_value(object: &MyObject): u64 {
        object.value
    }

    #[test_only]
    public fun create_object_for_testing(value: u64, ctx: &mut TxContext): MyObject {
        let sender = tx_context::sender(ctx);
        MyObject {
            id: object::new(ctx),
            value,
            owner: sender
        }
    }
}
