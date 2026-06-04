import { BillRecord } from '../model/BillRecord'
import { BillRepository } from '../database/BillRepository'

export class BillService {
  constructor(private repository: BillRepository = new BillRepository()) {}

  async addBill(record: BillRecord): Promise<boolean> {
    return this.repository.insert(record)
  }

  async updateBill(record: BillRecord): Promise<boolean> {
    return this.repository.update(record)
  }

  async deleteBill(id: string): Promise<boolean> {
    return this.repository.deleteById(id)
  }

  async getBillsByMonth(month: string): Promise<BillRecord[]> {
    return this.repository.queryByMonth(month)
  }

  async getBillsByDate(date: string): Promise<BillRecord[]> {
    return this.repository.queryByDate(date)
  }
}
