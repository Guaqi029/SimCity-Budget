export interface HomeBillItem {
  id: string
  type: 'income' | 'expense'
  icon: string
  title: string
  remark: string
  category: string
  assetName: string
  amount: number
  date: string
}

export interface HomeBillDayGroup {
  id: string
  dateTitle: string
  weekTitle: string
  income: number
  expense: number
  bills: HomeBillItem[]
}

export const HOME_BILL_GROUPS: HomeBillDayGroup[] = [
  {
    id: '2026-06-05',
    dateTitle: '今天',
    weekTitle: '周五',
    income: 0.04,
    expense: 168.98,
    bills: [
      {
        id: 'bill_today_1',
        type: 'expense',
        icon: '娱',
        title: '美团',
        remark: '旅游度假',
        category: '休闲娱乐',
        assetName: '余额宝',
        amount: 154.98,
        date: '2026-06-05'
      },
      {
        id: 'bill_today_2',
        type: 'expense',
        icon: '餐',
        title: '回首页',
        remark: '午餐',
        category: '食品餐饮',
        assetName: '余额宝',
        amount: 14,
        date: '2026-06-05'
      },
      {
        id: 'bill_today_3',
        type: 'income',
        icon: '收',
        title: '06月04日余额宝收益发放',
        remark: '理财盈利',
        category: '收入',
        assetName: '余额宝',
        amount: 0.04,
        date: '2026-06-05'
      }
    ]
  },
  {
    id: '2026-06-04',
    dateTitle: '昨天',
    weekTitle: '周四',
    income: 0.04,
    expense: 25.79,
    bills: [
      {
        id: 'bill_yesterday_1',
        type: 'expense',
        icon: '酒',
        title: '订单付款',
        remark: '饮料酒水',
        category: '食品餐饮',
        assetName: '余额宝',
        amount: 12.90,
        date: '2026-06-04'
      },
      {
        id: 'bill_yesterday_2',
        type: 'expense',
        icon: '餐',
        title: '回首页',
        remark: '晚餐',
        category: '食品餐饮',
        assetName: '余额宝',
        amount: 12.89,
        date: '2026-06-04'
      },
      {
        id: 'bill_yesterday_3',
        type: 'income',
        icon: '收',
        title: '06月03日余额宝收益发放',
        remark: '理财盈利',
        category: '收入',
        assetName: '余额宝',
        amount: 0.04,
        date: '2026-06-04'
      }
    ]
  },
  {
    id: '2026-06-03',
    dateTitle: '6月3日',
    weekTitle: '周三',
    income: 260.08,
    expense: 90,
    bills: [
      {
        id: 'bill_day3_1',
        type: 'expense',
        icon: '餐',
        title: '充值饭卡',
        remark: '午餐',
        category: '食品餐饮',
        assetName: '日常账本',
        amount: 50,
        date: '2026-06-03'
      },
      {
        id: 'bill_day3_2',
        type: 'income',
        icon: '入',
        title: '收入-其他',
        remark: '其他',
        category: '收入',
        assetName: '日常账本',
        amount: 260.08,
        date: '2026-06-03'
      },
      {
        id: 'bill_day3_3',
        type: 'expense',
        icon: '餐',
        title: '回首页',
        remark: '午餐',
        category: '食品餐饮',
        assetName: '日常账本',
        amount: 40,
        date: '2026-06-03'
      }
    ]
  }
]
