import { BillRecord } from '../../model/BillRecord'
import { BillTimeline } from './BillTimeline'
import { BillTimelineFilter, BillTimelineMapper } from './BillTimelineMapper'

@Component
export struct BillRecordTimeline {
  @Prop records: BillRecord[] = []
  @Prop filter: BillTimelineFilter = {}
  onOpenBill: (billId: string) => void = () => {}

  build() {
    BillTimeline({
      groups: BillTimelineMapper.toGroups(this.records, this.filter),
      onOpenBill: (billId: string) => {
        this.onOpenBill(billId)
      }
    })
  }
}
