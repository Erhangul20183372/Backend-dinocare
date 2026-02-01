import { TransactionManager } from "@shared/ts/db";
import { ErrorType, UnauthorizedError } from "@shared/ts/http";
import { AccessTokenDTO } from "@shared/ts/types";
import * as A from "../api/dtos/auth.dto";
import AuthRepository from "../data/auth.repository";
import { comparePassword, hashPassword } from "../utils/bcrypt";
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from "../utils/token";

export default class AuthService {
  constructor(
    private authRepository: AuthRepository,
    private transactionManager: TransactionManager
  ) {}

  async login(dto: A.LoginDto): Promise<AccessTokenDTO> {
    const identity = await this.authRepository.getByEmail({ email: dto.emailAddress });
    if (!identity) throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "Invalid credentials");

    const isValid = await comparePassword(dto.password, identity.password_hash);
    if (!isValid) throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "Invalid credentials");

    const user = await this.authRepository.getByIdentityId({ identityId: identity.id });
    if (!user) throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "Invalid credentials");

    const access = generateAccessToken(user.id);
    const refresh = generateRefreshToken(user.id);

    return {
      accessToken: access,
      refreshToken: refresh,
    };
  }

  async refresh(dto: A.RefreshDto): Promise<AccessTokenDTO> {
    try {
      const { appUserId } = verifyRefreshToken(dto.refreshToken);
      return {
        accessToken: generateAccessToken(appUserId),
        refreshToken: generateRefreshToken(appUserId),
      };
    } catch (e) {
      throw new UnauthorizedError(ErrorType.INVALID_REFRESH_TOKEN, "Invalid refresh token");
    }
  }

  async register(dto: A.RegisterDto): Promise<boolean> {
    const existingIdentity = await this.authRepository.getByEmail({ email: dto.emailAddress });
    if (existingIdentity)
      throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "User with that email already exists");

    await this.transactionManager.run(async () => {
      const domain = dto.emailAddress.split("@")[1];
      const organization = await this.authRepository.getOrganizationByDomain({ domain });
      if (!organization) throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "Could not find organization");

      const identity = await this.authRepository.createIdentity({
        emailAddress: dto.emailAddress,
        passwordHash: await hashPassword(dto.password),
      });
      if (!identity) throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "Could not create user");

      const user = await this.authRepository.createAppUser({
        identityId: identity.identity_id,
        firstName: dto.firstName,
        lastName: dto.lastName,
      });
      if (!user) throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "Could not create user");

      const organizationMembership = this.authRepository.createOrganizationMembership({
        appUserId: user.app_user_id,
        organizationId: organization.organization_id,
        role: dto.role,
      });
      if (!organizationMembership)
        throw new UnauthorizedError(ErrorType.INVALID_CREDENTIALS, "Could not create membership");
    }, [this.authRepository]);

    return true;
  }
}
