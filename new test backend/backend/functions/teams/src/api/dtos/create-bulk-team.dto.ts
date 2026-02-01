export interface BulkCreateTeamFailureDto {
  index: number;
  code: string;
  message: string;
}

export interface BulkCreateTeamResultDto {
  index: number;
  team: {
    id: string;
    name: string;
    color: string;
    organizationId: string;
  };
}

export interface BulkCreateTeamResponseDto {
  total: number;
  created: number;
  failed: BulkCreateTeamFailureDto[];
  results: BulkCreateTeamResultDto[];
}
