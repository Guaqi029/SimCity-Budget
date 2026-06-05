import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'
import { BillRecord, BillType } from '../model/BillRecord'

const BILL_RECORD_STORE_NAME: string = 'bill_record_store'
const BILL_RECORD_LIST_KEY: string = 'bill_record_list'

// 账单本地仓储：当前用 Preferences 保存 JSON 列表，后续可替换为关系型数据库。
export class BillRecordStore {
  static load(context: common.Context): Promise<BillRecord[]> {
    return preferences.getPreferences(context, BILL_RECORD_STORE_NAME)
      .then((store: preferences.Preferences) => {
        return store.get(BILL_RECORD_LIST_KEY, '[]')
      })
      .then((value: preferences.ValueType) => {
        if (typeof value !== 'string') {
          return []
        }
        const records = JSON.parse(value) as BillRecord[]
        if (!Array.isArray(records)) {
          return []
        }
        return records.map((record: BillRecord) => BillRecordStore.normalize(record))
      })
      .catch(() => {
        return []
      })
  }

  static save(context: common.Context, records: BillRecord[]): Promise<void> {
    return preferences.getPreferences(context, BILL_RECORD_STORE_NAME)
      .then((store: preferences.Preferences) => {
        store.put(BILL_RECORD_LIST_KEY, JSON.stringify(records))
        return store.flush()
      })
  }

  static add(context: common.Context, record: BillRecord): Promise<void> {
    return BillRecordStore.load(context)
      .then((records: BillRecord[]) => {
        return BillRecordStore.save(context, [record].concat(records))
      })
  }

  private static normalize(record: BillRecord): BillRecord {
    const amount = Number(record.amount)
    return {
      id: record.id,
      amount: amount === amount ? amount : 0,
      type: record.type as BillType,
      assetId: record.assetId === undefined ? '' : record.assetId,
      assetName: record.assetName === undefined ? '' : record.assetName,
      fromAssetId: record.fromAssetId === undefined ? '' : record.fromAssetId,
      fromAssetName: record.fromAssetName === undefined ? '' : record.fromAssetName,
      toAssetId: record.toAssetId === undefined ? '' : record.toAssetId,
      toAssetName: record.toAssetName === undefined ? '' : record.toAssetName,
      transferFee: record.transferFee === undefined ? 0 : Number(record.transferFee),
      categoryId: record.categoryId,
      categoryName: record.categoryName,
      billDate: record.billDate,
      month: record.month,
      remark: record.remark === undefined ? '' : record.remark,
      createTime: record.createTime,
      updateTime: record.updateTime,
      isDeleted: record.isDeleted === undefined ? false : record.isDeleted
    }
  }
}
