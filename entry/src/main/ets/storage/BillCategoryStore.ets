import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'
import { BillCategory } from '../model/BillCategory'
import { BillType } from '../model/BillType'
import { DEFAULT_BILL_CATEGORIES } from '../components/bill/BillCategoryConfig'

const BILL_CATEGORY_STORE_NAME: string = 'bill_category_store'
const BILL_CATEGORY_LIST_KEY: string = 'bill_category_list'

export class BillCategoryStore {
  static load(context: common.Context): Promise<BillCategory[]> {
    return preferences.getPreferences(context, BILL_CATEGORY_STORE_NAME)
      .then((store: preferences.Preferences) => {
        return store.get(BILL_CATEGORY_LIST_KEY, '')
      })
      .then((value: preferences.ValueType) => {
        if (typeof value !== 'string' || value.length === 0) {
          return DEFAULT_BILL_CATEGORIES
        }
        const categories = JSON.parse(value) as BillCategory[]
        if (!Array.isArray(categories)) {
          return DEFAULT_BILL_CATEGORIES
        }
        return BillCategoryStore.mergeSystemCategories(categories.map((category: BillCategory) => BillCategoryStore.normalize(category)))
      })
      .catch(() => {
        return DEFAULT_BILL_CATEGORIES
      })
  }

  static save(context: common.Context, categories: BillCategory[]): Promise<void> {
    return preferences.getPreferences(context, BILL_CATEGORY_STORE_NAME)
      .then((store: preferences.Preferences) => {
        store.put(BILL_CATEGORY_LIST_KEY, JSON.stringify(categories))
        return store.flush()
      })
  }

  static activeByType(categories: BillCategory[], type: BillType): BillCategory[] {
    const result: BillCategory[] = []
    for (let index = 0; index < categories.length; index++) {
      if (!categories[index].isDeleted && categories[index].type === type) {
        result.push(categories[index])
      }
    }
    return result
  }

  private static normalize(category: BillCategory): BillCategory {
    const now = new Date().toISOString()
    return {
      id: category.id,
      name: category.name,
      type: category.type as BillType,
      iconId: category.iconId === undefined || category.iconId.length === 0 ? 'icon_other' : category.iconId,
      createTime: category.createTime === undefined ? now : category.createTime,
      updateTime: category.updateTime === undefined ? now : category.updateTime,
      isSystem: category.isSystem === undefined ? false : category.isSystem,
      isDeleted: category.isDeleted === undefined ? false : category.isDeleted
    }
  }

  private static mergeSystemCategories(categories: BillCategory[]): BillCategory[] {
    const result: BillCategory[] = categories.concat([])
    for (let index = 0; index < DEFAULT_BILL_CATEGORIES.length; index++) {
      if (BillCategoryStore.findIndexById(result, DEFAULT_BILL_CATEGORIES[index].id) < 0) {
        result.push(DEFAULT_BILL_CATEGORIES[index])
      }
    }
    return result
  }

  private static findIndexById(categories: BillCategory[], id: string): number {
    for (let index = 0; index < categories.length; index++) {
      if (categories[index].id === id) {
        return index
      }
    }
    return -1
  }
}
