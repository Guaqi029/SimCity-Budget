export type BillType = 'income' | 'expense'

export interface BillRecord {
  id: string
  amount: number
  type: BillType
  categoryId: string
  categoryName: string
  billDate: string
  month: string
  remark?: string
  createTime: string
  updateTime: string
  isDeleted: boolean
}
