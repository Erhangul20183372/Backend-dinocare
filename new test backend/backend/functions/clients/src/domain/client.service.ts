import * as C from "../api/dtos/client.dto";
import * as DA from "../api/dtos/device-assignment.dto";
import ClientRepository from "../infrastructure/client.repository";
import {
  AllClientDevicesDto,
  ClientCreatedDto,
  ClientDeviceDeletedDto,
  ClientDevicePatchedDto,
  ClientsByIdDto,
  ClientWithTeamDto,
  CreatedClientDeviceDto,
  DeletedClientDto,
  PatchedClientDto,
} from "./dtos";
import {
  AllClientsDevicesMapper,
  AllClientsMapper,
  ClientCreatedMapper,
  ClientDeviceDeletedMapper,
  ClientDevicePatchedMapper,
  CreatedClientDeviceMapper,
  DeletedClientMapper,
  GetClientByIdMapper,
  PatchClientMapper,
} from "./mappers";

export default class ClientService {
  constructor(private clientRepository: ClientRepository) {}

  async createClient(dto: C.CreateClientDto): Promise<ClientCreatedDto> {
    const row = await this.clientRepository.create({
      gender: dto.gender,
      firstName: dto.firstName,
      lastName: dto.lastName,
      teamId: dto.teamId,
    });
    return ClientCreatedMapper.toResponse(row);
  }

  async createClients(dto: C.CreateClientBulkDto): Promise<ClientCreatedDto[]> {
    const rows = await this.clientRepository.createBulk(dto.clients);
    return rows.map(ClientCreatedMapper.toResponse);
  }

  async getClientsWithTeams(dto: C.GetClientsDto): Promise<ClientWithTeamDto[]> {
    const rows = await this.clientRepository.findAll(
      {
        organizationId: dto.organizationId,
        teamId: dto.teamId,
        clientStatus: dto.status,
        search: dto.search,
      },
      {
        limit: dto.limit,
        offset: dto.offset,
      }
    );
    return rows.map(AllClientsMapper.toResponse);
  }

  async getClientById(dto: C.GetClientByIdDto): Promise<ClientsByIdDto | null> {
    const row = await this.clientRepository.getById({ id: dto.id });
    if (!row) return null;
    return GetClientByIdMapper.toResponse(row);
  }

  async patchClient(dto: C.PatchClientDto): Promise<PatchedClientDto | null> {
    const row = await this.clientRepository.patchOne(
      {
        id: dto.id,
      },
      {
        gender: dto.gender,
        firstName: dto.firstName,
        lastName: dto.lastName,
        teamId: dto.teamId,
        archivedOn: dto.archivedOn,
        archivedBy: dto.archivedBy,
      }
    );
    if (!row) return null;
    return PatchClientMapper.toResponse(row);
  }

  async deleteClient(dto: C.DeleteClientDto): Promise<DeletedClientDto | null> {
    const row = await this.clientRepository.delete({ id: dto.id });
    if (!row) return null;
    return DeletedClientMapper.toResponse(row);
  }

  async createClientDevice(dto: DA.CreateDeviceAssignmentDto): Promise<CreatedClientDeviceDto | null> {
    const exists = await this.clientRepository.checkClientDeviceAssignment({
      clientId: dto.clientId,
      deviceId: dto.deviceId,
    });

    if (exists) return null;

    const rows = await this.clientRepository.createDeviceAssignment({
      clientId: dto.clientId,
      deviceId: dto.deviceId,
      location: dto.location,
    });
    if (!rows) return null;
    return CreatedClientDeviceMapper.toResponse(rows);
  }

  async getClientDevices(dto: DA.GetDeviceAssignmentsDto): Promise<AllClientDevicesDto | null> {
    const rows = await this.clientRepository.findAllDevices(
      { id: dto.clientId },
      { limit: dto.limit, offset: dto.offset }
    );
    if (rows.length === 0) return null;
    return AllClientsDevicesMapper.toResponse(rows);
  }

  async patchClientDevice(dto: DA.PatchDeviceAssignmentDto): Promise<ClientDevicePatchedDto | null> {
    const row = await this.clientRepository.patchDeviceAssignment(
      { location: dto.location },
      { clientId: dto.clientId, deviceId: dto.deviceId }
    );
    if (!row) return null;
    return ClientDevicePatchedMapper.toResponse(row);
  }

  async deleteClientDevice(dto: DA.DeleteDeviceAssignmentDto): Promise<ClientDeviceDeletedDto | null> {
    const row = await this.clientRepository.deleteDeviceAssignment({ clientId: dto.clientId, deviceId: dto.deviceId });
    if (!row) return null;
    return ClientDeviceDeletedMapper.toResponse(row);
  }
}
