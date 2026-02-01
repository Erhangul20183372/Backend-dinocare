export interface OneUserArchiveDto {
  id: string;
  firstName: string;
  lastName: string;
  archivedOn: Date | null;
  archivedBy: string | null;
}
