import { ErrorType, NotFoundError } from "@shared/ts";
import * as AU from "../api/dtos/user.dto";
import { UserRepository } from "../data/user.repository";
import { AllUsersDto, OneUserArchiveDto, OneUserDto } from "./dtos";
import { AllUsersMapper, OneUserArchiveMapper, OneUserMapper } from "./mappers";

export class UserService {
  constructor(private userRepository: UserRepository) {}

  async getAll(dto: AU.GetUsersDto): Promise<AllUsersDto[]> {
    const rows = await this.userRepository.getAll(
      {
        teamId: dto.teamId,
        teamRole: dto.teamRole,
        organizationId: dto.organizationId,
        organizationRole: dto.organizationRole,
        search: dto.search,
      },
      { limit: dto.limit, offset: dto.offset }
    );

    return AllUsersMapper.toResponse(rows);
  }

  async getOne(dto: AU.GetUserByIdDto): Promise<OneUserDto> {
    const rows = await this.userRepository.getById({ id: dto.id });
    if (!rows) throw new NotFoundError(ErrorType.USER_NOT_FOUND, "User not found");

    return OneUserMapper.toResponse(rows);
  }

  async getMe(): Promise<OneUserDto> {
    const rows = await this.userRepository.getUserMe();
    if (!rows) throw new NotFoundError(ErrorType.USER_NOT_FOUND, "User not found");

    return OneUserMapper.toResponse(rows);
  }

  async patch(dto: AU.PatchUserDto): Promise<OneUserDto | null> {
    const rows = await this.userRepository.patchUser(
      { firstName: dto.firstName, lastName: dto.lastName },
      { id: dto.id }
    );
    if (!rows) throw new NotFoundError(ErrorType.USER_NOT_FOUND, "User not found");

    return OneUserMapper.toResponse(rows);
  }

  async archive(dto: AU.ArchiveUserDto): Promise<OneUserArchiveDto | null> {
    const rows = await this.userRepository.archiveUser({ id: dto.id });
    if (!rows) throw new NotFoundError(ErrorType.USER_NOT_FOUND, "User not found");

    return OneUserArchiveMapper.toResponse(rows);
  }
}
