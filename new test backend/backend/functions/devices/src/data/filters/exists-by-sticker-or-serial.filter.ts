import { BaseConditionable, Condition } from "@shared/ts/sql/fragments";

export type ExistsByStickerOrSerialFilter = {
  stickerId: string;
  serialNumber: string;
};

export class ExistsByStickerOrSerialConditionable extends BaseConditionable<ExistsByStickerOrSerialFilter> {
  protected getConditions(tables: Record<string, string>) {
    const filters = this.getFilters();
    const conditions: Condition[] = [];

    conditions.push({
      sql: `(${tables.device}.sticker_id = <?> OR ${tables.device}.serial_number = <?>)`,
      value: [filters.stickerId, filters.serialNumber],
    });

    return conditions;
  }
}
