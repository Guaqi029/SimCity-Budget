export type AssetGroup = 'fund' | 'credit' | 'stored_value' | 'investment' | 'second_hand' | 'debt'

export type AssetType =
  'cash' |
  'alipay' |
  'wechat' |
  'bank_card' |
  'qq_wallet' |
  'jd_finance' |
  'credit_card' |
  'huabei' |
  'baitiao' |
  'member_card' |
  'bus_card' |
  'meal_card' |
  'deposit' |
  'insurance' |
  'virtual_currency' |
  'house' |
  'car' |
  'payable' |
  'receivable' |
  'reimbursement' |
  'custom'

export type AssetFlowType = 'income' | 'expense' | 'transfer_in' | 'transfer_out' | 'adjustment'

export interface AssetAccount {
  id: string
  type: AssetType
  group: AssetGroup
  name: string
  balance: number
  shortName: string
  icon: string
  color: string
  cardNo?: string
  remark?: string
  includeInTotal: boolean
  bookScope: string
  createTime: string
  updateTime: string
  isDeleted: boolean
}

export interface AssetFlowRecord {
  id: string
  assetId: string
  billId?: string
  type: AssetFlowType
  // 流水 amount 使用正数记录变动规模，方向由 type 决定。
  amount: number
  beforeBalance: number
  afterBalance: number
  // 转账流水记录对方资产，便于详情页展示资金去向/来源。
  relatedAssetId?: string
  relatedAssetName?: string
  remark?: string
  createTime: string
}

export interface AssetTypeOption {
  type: AssetType
  group: AssetGroup
  title: string
  icon: string
  color: string
}
