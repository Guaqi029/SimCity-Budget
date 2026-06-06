import { BillCategory } from '../../model/BillCategory'

const SYSTEM_TIME: string = '2026-01-01T00:00:00.000Z'

function systemCategory(id: string, name: string, type: 'expense' | 'income' | 'transfer', iconId: string): BillCategory {
  return {
    id: id,
    name: name,
    type: type,
    iconId: iconId,
    createTime: SYSTEM_TIME,
    updateTime: SYSTEM_TIME,
    isSystem: true,
    isDeleted: false
  }
}

export const DEFAULT_BILL_CATEGORIES: BillCategory[] = [
  systemCategory('expense_food', '餐饮', 'expense', 'icon_drinks'),
  systemCategory('expense_shopping', '购物', 'expense', 'icon_shopping'),
  systemCategory('expense_transport', '交通', 'expense', 'icon_transport'),
  systemCategory('expense_daily', '日用品', 'expense', 'icon_commodity_daily_use'),
  systemCategory('expense_entertainment', '娱乐', 'expense', 'icon_game'),
  systemCategory('expense_medicine', '医疗', 'expense', 'icon_medicine'),
  systemCategory('expense_book', '学习', 'expense', 'icon_book'),
  systemCategory('expense_clothing', '服饰', 'expense', 'icon_clothing'),
  systemCategory('expense_pet', '宠物', 'expense', 'icon_pet'),
  systemCategory('expense_public_benefit', '公益', 'expense', 'public_benifit'),
  systemCategory('expense_other', '其他', 'expense', 'icon_other'),

  systemCategory('income_salary', '工资', 'income', 'icon_wealth_management'),
  systemCategory('income_part_time', '兼职', 'income', 'icon_book'),
  systemCategory('income_bonus', '奖金', 'income', 'icon_gift'),
  systemCategory('income_finance', '理财', 'income', 'icon_wealth_management'),
  systemCategory('income_refund', '退款', 'income', 'icon_shopping'),
  systemCategory('income_reimburse', '报销', 'income', 'file'),
  systemCategory('income_other', '其他', 'income', 'icon_other'),

  systemCategory('transfer_account', '账户转账', 'transfer', 'wallet'),
  systemCategory('transfer_repay', '还信用卡', 'transfer', 'icon_mortgage'),
  systemCategory('transfer_top_up', '充值', 'transfer', 'icon_virtual_top_up'),
  systemCategory('transfer_other', '其他转账', 'transfer', 'icon_other')
]
