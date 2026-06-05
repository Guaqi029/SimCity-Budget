import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'

const BILL_DRAFT_STORE_NAME: string = 'bill_draft_store'
const LAST_ASSET_ID_KEY: string = 'last_asset_id'

// 新增账单草稿偏好：保存跨页面/重启后仍需要沿用的轻量选择项。
export class BillDraftPreferenceStore {
  static loadLastAssetId(context: common.Context): Promise<string> {
    return preferences.getPreferences(context, BILL_DRAFT_STORE_NAME)
      .then((store: preferences.Preferences) => {
        return store.get(LAST_ASSET_ID_KEY, '')
      })
      .then((value: preferences.ValueType) => {
        return typeof value === 'string' ? value : ''
      })
      .catch(() => {
        return ''
      })
  }

  static saveLastAssetId(context: common.Context, assetId: string): Promise<void> {
    return preferences.getPreferences(context, BILL_DRAFT_STORE_NAME)
      .then((store: preferences.Preferences) => {
        store.put(LAST_ASSET_ID_KEY, assetId)
        return store.flush()
      })
  }
}
