export interface IdentityDB {
  id: string;
  email_address: string;
  password_hash: string;
}

export interface IdentityDTO {
  id: string;
  emailAddress: string;
  passwordHash: string;
}

export const toIdentityDTO = (dbModel: IdentityDB): IdentityDTO => ({
  id: dbModel.id,
  emailAddress: dbModel.email_address,
  passwordHash: dbModel.password_hash,
});
