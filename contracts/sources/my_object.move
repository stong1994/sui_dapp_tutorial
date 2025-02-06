module sui_dapp_tutorial::my_object {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field;

    // 错误码定义
    const ERROR_UNAUTHORIZED: u64 = 1;
    const ERROR_INVALID_VALUE: u64 = 2;

    /// 主要业务对象，实现基础数据存储功能
    struct MyObject has key, store {
        id: UID,
        value: u64,
        owner: address
    }

    /// 创建新的MyObject对象
    /// * 参数 `value`: 初始值
    /// * 参数 `ctx`: 交易上下文
    public entry fun create_object(
        value: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        let object = MyObject {
            id: object::new(ctx),
            value,
            owner: sender
        };
        
        // 将对象转移给创建者
        transfer::public_transfer(object, sender);
    }

    /// 更新对象的值
    /// * 参数 `object`: 目标对象
    /// * 参数 `new_value`: 新的值
    /// * 参数 `ctx`: 交易上下文
    public entry fun update_value(
        object: &mut MyObject,
        new_value: u64,
        ctx: &TxContext
    ) {
        // 权限检查
        assert!(object.owner == tx_context::sender(ctx), ERROR_UNAUTHORIZED);
        object.value = new_value;
    }

    // === Getter函数 ===
    
    /// 获取对象的当前值
    public fun get_value(object: &MyObject): u64 {
        object.value
    }

    /// 获取对象的所有者
    public fun get_owner(object: &MyObject): address {
        object.owner
    }
}
