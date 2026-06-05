import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'
import { AssetAccount, AssetGroup, AssetType } from '../model/AssetAccount'

const ASSET_STORE_NAME: string = 'asset_account_store'
const ASSET_LIST_KEY: string = 'asset_account_list'

// 资产账户本地仓储：当前使用 Preferences 保存 JSON，后续需要复杂查询时可替换为数据库。
export class AssetAccountStore {
  static load(context: common.Context): Promise<AssetAccount[]> {
    return preferences.getPreferences(context, ASSET_STORE_NAME)
      .then((store: preferences.Preferences) => {
        return store.get(ASSET_LIST_KEY, '[]')
      })
      .then((value: preferences.ValueType) => {
        if (typeof value !== 'string') {
          return []
        }
        const assets = JSON.parse(value) as AssetAccount[]
        if (!Array.isArray(assets)) {
          return []
        }
        return assets.map((asset: AssetAccount) => AssetAccountStore.normalize(asset))
      })
      .catch(() => {
        return []
      })
  }

  static save(context: common.Context, assets: AssetAccount[]): Promise<void> {
    return preferences.getPreferences(context, ASSET_STORE_NAME)
      .then((store: preferences.Preferences) => {
        store.put(ASSET_LIST_KEY, JSON.stringify(assets))
        return store.flush()
      })
  }

  // 兼容旧版本本地数据：缺失字段补默认值，避免列表能显示但汇总金额不参与计算。
  private static normalize(asset: AssetAccount): AssetAccount {
    const balance = Number(asset.balance)
    return {
      id: asset.id,
      type: asset.type as AssetType,
      group: asset.group as AssetGroup,
      name: asset.name,
      balance: balance === balance ? balance : 0,
      shortName: asset.shortName === undefined ? '' : asset.shortName,
      icon: asset.icon,
      color: asset.color,
      cardNo: asset.cardNo === undefined ? '' : asset.cardNo,
      remark: asset.remark === undefined ? '' : asset.remark,
      includeInTotal: asset.includeInTotal === undefined ? true : asset.includeInTotal,
      bookScope: asset.bookScope === undefined ? '全部账本' : asset.bookScope,
      createTime: asset.createTime === undefined ? '' : asset.createTime,
      updateTime: asset.updateTime === undefined ? '' : asset.updateTime,
      isDeleted: asset.isDeleted === undefined ? false : asset.isDeleted
    }
  }
}
