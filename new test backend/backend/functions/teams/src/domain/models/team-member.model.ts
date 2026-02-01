export class TeamMemberModel {
  constructor(
    public userId: string,
    public firstName: string,
    public lastName: string,
    public role: string,
    public memberSince: Date,
    public memberUntil: Date | null,
    public invitedBy: string
  ) {}
}
