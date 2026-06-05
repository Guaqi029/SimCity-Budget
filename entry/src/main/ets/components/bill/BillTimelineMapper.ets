import { BillRecord } from '../../model/BillRecord'
import { BillTimelineDayGroup, BillTimelineItem } from './BillTimeline'

export interface BillTimelineFilter {
  // 指定资产：收入/支出匹配 assetId，转账同时匹配 from/to 账户。
  assetId?: string
  // 指定某一天，格式：yyyy-MM-dd。
  day?: string
  // 日期区间，格式：yyyy-MM-dd，包含边界。
  startDate?: string
  endDate?: string
  // 最大条数。Home 使用 30，详情页可以不传。
  limit?: number
}

export class BillTimelineMapper {
  static toGroups(records: BillRecord[], filter: BillTimelineFilter = {}): BillTimelineDayGroup[] {
    const filteredRecords = BillTimelineMapper.filterRecords(records, filter)
    const groups: BillTimelineDayGroup[] = []

    for (let index = 0; index < filteredRecords.length; index++) {
      const record = filteredRecords[index]
      const date = new Date(record.billDate)
      const key = BillTimelineMapper.dateKey(date)
      let groupIndex = BillTimelineMapper.findGroupIndex(groups, key)

      if (groupIndex < 0) {
        groups.push({
          id: key,
          dateTitle: BillTimelineMapper.dateTitle(date),
          weekTitle: BillTimelineMapper.weekTitle(date),
          income: 0,
          expense: 0,
          bills: []
        })
        groupIndex = groups.length - 1
      }

      if (record.type === 'income') {
        groups[groupIndex].income += record.amount
      } else if (record.type === 'expense') {
        groups[groupIndex].expense += record.amount
      }
      groups[groupIndex].bills.push(BillTimelineMapper.toItem(record))
    }

    return groups
  }

  static filterRecords(records: BillRecord[], filter: BillTimelineFilter = {}): BillRecord[] {
    const result: BillRecord[] = []

    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      if (record.isDeleted || !BillTimelineMapper.matchAsset(record, filter.assetId)) {
        continue
      }

      const key = BillTimelineMapper.dateKey(new Date(record.billDate))
      if (filter.day !== undefined && key !== filter.day) {
        continue
      }
      if (filter.startDate !== undefined && key < filter.startDate) {
        continue
      }
      if (filter.endDate !== undefined && key > filter.endDate) {
        continue
      }

      result.push(record)
    }

    result.sort((left: BillRecord, right: BillRecord) => {
      return new Date(right.billDate).getTime() - new Date(left.billDate).getTime()
    })

    if (filter.limit !== undefined && filter.limit > 0 && result.length > filter.limit) {
      return result.slice(0, filter.limit)
    }
    return result
  }

  static calculateExpense(records: BillRecord[], filter: BillTimelineFilter = {}): number {
    const filteredRecords = BillTimelineMapper.filterRecords(records, filter)
    let total = 0
    for (let index = 0; index < filteredRecords.length; index++) {
      if (filteredRecords[index].type === 'expense') {
        total += filteredRecords[index].amount
      }
    }
    return total
  }

  private static toItem(record: BillRecord): BillTimelineItem {
    return {
      id: record.id,
      type: record.type,
      icon: BillTimelineMapper.billIcon(record),
      title: record.remark !== undefined && record.remark.length > 0 ? record.remark : record.categoryName,
      remark: record.remark === undefined || record.remark.length === 0 ? record.categoryName : record.categoryName,
      category: record.type === 'transfer' ? '转账' : record.categoryName,
      assetName: BillTimelineMapper.billAssetName(record),
      amount: record.amount,
      date: BillTimelineMapper.dateKey(new Date(record.billDate))
    }
  }

  private static matchAsset(record: BillRecord, assetId?: string): boolean {
    if (assetId === undefined || assetId.length === 0) {
      return true
    }
    if (record.assetId === assetId || record.fromAssetId === assetId || record.toAssetId === assetId) {
      return true
    }
    return false
  }

  private static billIcon(record: BillRecord): string {
    if (record.type === 'income') {
      return '收'
    }
    if (record.type === 'transfer') {
      return '转'
    }
    return record.categoryName.length > 0 ? record.categoryName.substring(0, 1) : '支'
  }

  private static billAssetName(record: BillRecord): string {
    if (record.type === 'transfer') {
      const fromName = record.fromAssetName !== undefined && record.fromAssetName.length > 0 ? record.fromAssetName : '无账户'
      const toName = record.toAssetName !== undefined && record.toAssetName.length > 0 ? record.toAssetName : '无账户'
      return fromName + ' → ' + toName
    }
    if (record.assetName !== undefined && record.assetName.length > 0) {
      return record.assetName
    }
    return '无账户'
  }

  private static findGroupIndex(groups: BillTimelineDayGroup[], id: string): number {
    for (let index = 0; index < groups.length; index++) {
      if (groups[index].id === id) {
        return index
      }
    }
    return -1
  }

  private static dateTitle(date: Date): string {
    const today = new Date()
    if (BillTimelineMapper.dateKey(date) === BillTimelineMapper.dateKey(today)) {
      return '今天'
    }
    const yesterday = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 1)
    if (BillTimelineMapper.dateKey(date) === BillTimelineMapper.dateKey(yesterday)) {
      return '昨天'
    }
    return (date.getMonth() + 1).toString() + '月' + date.getDate().toString() + '日'
  }

  private static weekTitle(date: Date): string {
    const weeks: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return weeks[date.getDay()]
  }

  static dateKey(date: Date): string {
    return date.getFullYear().toString() + '-' + BillTimelineMapper.pad2(date.getMonth() + 1) + '-' +
    BillTimelineMapper.pad2(date.getDate())
  }

  static monthStartKey(date: Date): string {
    return date.getFullYear().toString() + '-' + BillTimelineMapper.pad2(date.getMonth() + 1) + '-01'
  }

  static monthEndKey(date: Date): string {
    const endDate = new Date(date.getFullYear(), date.getMonth() + 1, 0)
    return BillTimelineMapper.dateKey(endDate)
  }

  private static pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }
}
