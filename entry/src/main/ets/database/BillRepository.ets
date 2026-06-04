import { BillRecord } from '../model/BillRecord'

export class BillRepository {
  async insert(_record: BillRecord): Promise<boolean> {
    return true
  }

  async update(_record: BillRecord): Promise<boolean> {
    return true
  }

  async deleteById(_id: string): Promise<boolean> {
    return true
  }

  async queryByMonth(_month: string): Promise<BillRecord[]> {
    return []
  }

  async queryByDate(_date: string): Promise<BillRecord[]> {
    return []
  }
}
