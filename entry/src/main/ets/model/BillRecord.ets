export type BillType = 'income' | 'expense' | 'transfer'

export interface BillRecord {
  id: string
  amount: number
  type: BillType
  // 收入/支出使用 assetId；收入加款，支出扣款。
  assetId?: string
  assetName?: string
  // 转账使用 from/to 资产；from 扣款，to 加款，transferFee 只从 from 扣除。
  fromAssetId?: string
  fromAssetName?: string
  toAssetId?: string
  toAssetName?: string
  transferFee?: number
  categoryId: string
  categoryName: string
  billDate: string
  month: string
  remark?: string
  createTime: string
  updateTime: string
  isDeleted: boolean
}
