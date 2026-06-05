import { AssetTypeOption } from '../../model/AssetAccount'
import { AssetTypeSection } from './AssetTypeSheet'

export const DEFAULT_ASSET_TYPE_OPTION: AssetTypeOption = {
  type: 'cash',
  group: 'fund',
  title: '现金',
  icon: '¥',
  color: '#F6C44F'
}

export const ASSET_TYPE_SECTIONS: AssetTypeSection[] = [
  {
    title: '资金账户',
    options: [
      { type: 'cash', group: 'fund', title: '现金', icon: '¥', color: '#F6C44F' },
      { type: 'alipay', group: 'fund', title: '支付宝', icon: '支', color: '#22A7F2' },
      { type: 'wechat', group: 'fund', title: '微信钱包', icon: '微', color: '#14BF37' },
      { type: 'bank_card', group: 'fund', title: '银行卡', icon: '卡', color: '#F5BE22' },
      { type: 'qq_wallet', group: 'fund', title: 'QQ钱包', icon: 'Q', color: '#111111' },
      { type: 'jd_finance', group: 'fund', title: '京东金融', icon: '京', color: '#F04B37' },
      { type: 'custom', group: 'fund', title: '自定义', icon: '★', color: '#55B8A7' }
    ]
  },
  {
    title: '信贷账户',
    options: [
      { type: 'credit_card', group: 'credit', title: '信用卡', icon: '卡', color: '#C7CCD8' },
      { type: 'huabei', group: 'credit', title: '花呗', icon: '花', color: '#2B86F0' },
      { type: 'baitiao', group: 'credit', title: '白条', icon: '白', color: '#E95A64' },
      { type: 'custom', group: 'credit', title: '自定义', icon: '★', color: '#55B8A7' }
    ]
  },
  {
    title: '充值账户',
    options: [
      { type: 'member_card', group: 'stored_value', title: '会员卡', icon: '会', color: '#F7C739' },
      { type: 'bus_card', group: 'stored_value', title: '公交卡', icon: '交', color: '#66C26F' },
      { type: 'meal_card', group: 'stored_value', title: '饭卡', icon: '餐', color: '#F39A38' },
      { type: 'deposit', group: 'stored_value', title: '押金', icon: '押', color: '#2E8AF7' },
      { type: 'custom', group: 'stored_value', title: '自定义', icon: '★', color: '#55B8A7' }
    ]
  },
  // {
  //   title: '投资理财',
  //   options: [
  //     { type: 'insurance', group: 'investment', title: '保险', icon: '保', color: '#178FD1' },
  //     { type: 'virtual_currency', group: 'investment', title: '虚拟货币', icon: 'B', color: '#D565D8' },
  //     { type: 'custom', group: 'investment', title: '自定义', icon: '★', color: '#55B8A7' }
  //   ]
  // },
  // {
  //   title: '二手货物',
  //   options: [
  //     { type: 'house', group: 'second_hand', title: '房子', icon: '房', color: '#ED5F65' },
  //     { type: 'car', group: 'second_hand', title: '车子', icon: '车', color: '#4DB5E8' },
  //     { type: 'custom', group: 'second_hand', title: '自定义', icon: '★', color: '#55B8A7' }
  //   ]
  // },
  // {
  //   title: '债务',
  //   options: [
  //     { type: 'payable', group: 'debt', title: '应付款/借入', icon: '付', color: '#FFC63D' },
  //     { type: 'receivable', group: 'debt', title: '应收款/借出', icon: '收', color: '#FFC63D' },
  //     { type: 'reimbursement', group: 'debt', title: '报销账户', icon: '报', color: '#2F86F6' }
  //   ]
  // }
]
