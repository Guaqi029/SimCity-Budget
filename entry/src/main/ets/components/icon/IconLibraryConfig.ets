export type IconResource = Resource | string

export interface IconLibraryItem {
  id: string
  name: string
  resource: IconResource
}

// 图标库配置：后续要增加图标，只需要在这里追加一项。
// id 用作唯一标识，name 是中文显示名，resource 是 resources/base/media 下的资源引用。
export const ICON_LIBRARY_ITEMS: IconLibraryItem[] = [
  { id: 'icon_beer', name: '酒水', resource: $r('app.media.icon_beer') },
  { id: 'icon_book', name: '书籍', resource: $r('app.media.icon_book') },
  { id: 'icon_clothing', name: '服饰', resource: $r('app.media.icon_clothing') },
  { id: 'icon_commodity_daily_use', name: '日用品', resource: $r('app.media.icon_commodity_daily_use') },
  { id: 'icon_cosmetics', name: '美妆', resource: $r('app.media.icon_cosmetics') },
  { id: 'icon_drinks', name: '饮品', resource: $r('app.media.icon_drinks') },
  { id: 'icon_exercise', name: '运动', resource: $r('app.media.icon_exercise') },
  { id: 'icon_fitment', name: '装修', resource: $r('app.media.icon_fitment') },
  { id: 'icon_fruit', name: '水果', resource: $r('app.media.icon_fruit') },
  { id: 'icon_furniture', name: '家具', resource: $r('app.media.icon_furniture') },
  { id: 'icon_game', name: '游戏', resource: $r('app.media.icon_game') },
  { id: 'icon_gasoline', name: '加油', resource: $r('app.media.icon_gasoline') },
  { id: 'icon_gift', name: '礼物', resource: $r('app.media.icon_gift') },
  { id: 'icon_home_appliance', name: '家电', resource: $r('app.media.icon_home_appliance') },
  { id: 'icon_medicine', name: '医疗', resource: $r('app.media.icon_medicine') },
  { id: 'icon_mortgage', name: '房贷', resource: $r('app.media.icon_mortgage') },
  { id: 'icon_movie', name: '电影', resource: $r('app.media.icon_movie') },
  { id: 'icon_other', name: '其他', resource: $r('app.media.icon_other') },
  { id: 'icon_pet', name: '宠物', resource: $r('app.media.icon_pet') },
  { id: 'icon_shopping', name: '购物', resource: $r('app.media.icon_shopping') },
  { id: 'icon_snacks', name: '零食', resource: $r('app.media.icon_snacks') },
  { id: 'icon_tax', name: '税费', resource: $r('app.media.icon_tax') },
  { id: 'icon_transport', name: '交通', resource: $r('app.media.icon_transport') },
  { id: 'icon_vegetable', name: '蔬菜', resource: $r('app.media.icon_vegetable') },
  { id: 'icon_virtual_top_up', name: '虚拟充值', resource: $r('app.media.icon_virtual_top_up') },
  { id: 'icon_water_electricity_gas', name: '水电燃气', resource: $r('app.media.icon_water_electricity_gas') },
  { id: 'icon_wealth_management', name: '理财', resource: $r('app.media.icon_wealth_management') },
  { id: 'add', name: '新增', resource: $r('app.media.add') },
  { id: 'calendar', name: '日历', resource: $r('app.media.calendar') },
  { id: 'wallet', name: '钱包', resource: $r('app.media.wallet') },
  { id: 'home', name: '首页', resource: $r('app.media.home') },
  { id: 'calculate', name: '统计', resource: $r('app.media.calculate') },
  { id: 'file', name: '账本', resource: $r('app.media.file') },
  { id: 'search', name: '搜索', resource: $r('app.media.search') },
  { id: 'more', name: '更多', resource: $r('app.media.more') },
  { id: 'arrow_back', name: '返回', resource: $r('app.media.arrow_back') },
  { id: 'arrow_forward', name: '前进', resource: $r('app.media.arrow_forward') },
  { id: 'arrow_up', name: '向上', resource: $r('app.media.arrow_up') },
  { id: 'arrow_down', name: '向下', resource: $r('app.media.arrow_down') },
  { id: 'build_house_1', name: '房屋', resource: $rawfile('kenney/build_nice_house_1.png') },
  { id: 'build_house_2', name: '建筑', resource: $rawfile('kenney/build_nice_house_2.png') },
  { id: 'tent_1', name: '帐篷', resource: $rawfile('kenney/build_poor_tent_1.png') },
  { id: 'app_icon', name: '记账岛', resource: $r('app.media.icon') },
  { id: 'public_benifit', name: '公益', resource: $r('app.media.icon_public_benefit')  }
]

export function iconResourceById(iconId: string): IconResource {
  for (let index = 0; index < ICON_LIBRARY_ITEMS.length; index++) {
    if (ICON_LIBRARY_ITEMS[index].id === iconId) {
      return ICON_LIBRARY_ITEMS[index].resource
    }
  }
  return $r('app.media.icon_other')
}

export function iconNameById(iconId: string): string {
  for (let index = 0; index < ICON_LIBRARY_ITEMS.length; index++) {
    if (ICON_LIBRARY_ITEMS[index].id === iconId) {
      return ICON_LIBRARY_ITEMS[index].name
    }
  }
  return '其他'
}
