import { BillType } from './BillType'

export interface BillCategory {
  id: string
  name: string
  type: BillType
  iconId: string
  createTime: string
  updateTime: string
  isSystem: boolean
  isDeleted: boolean
}
