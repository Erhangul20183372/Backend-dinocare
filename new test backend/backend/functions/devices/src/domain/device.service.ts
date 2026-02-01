import * as D from "../api/dtos/device.dto";
import DeviceRepository from "../data/device.repository";
import { AllDevicesDto, DeviceCreatedDto, DevicePatchedDto, OneDeviceDto } from "./dtos";
import { AllDevicesMapper, DeviceCreatedMapper, DevicePatchedMapper, OneDeviceMapper } from "./mappers";

export default class DeviceService {
  constructor(private deviceRepository: DeviceRepository) {}

  async getAllDevices(dto: D.GetDevicesDto): Promise<AllDevicesDto[]> {
    const rows = await this.deviceRepository.getAll(
      {
        organizationId: dto.organizationId,
        teamId: dto.teamId,
        clientId: dto.clientId,
        type: dto.type,
        status: dto.status,
        search: dto.search,
      },
      { offset: dto.offset, limit: dto.limit }
    );
    if (rows.length === 0) return [];
    return rows.map(AllDevicesMapper.toResponse);
  }

  async createDevice(dto: D.CreateDevicesDto): Promise<DeviceCreatedDto | null> {
    const exists = await this.deviceRepository.existsByStickerOrSerial({
      stickerId: dto.stickerId,
      serialNumber: dto.serialNumber,
    });
    if (exists) return null;

    const row = await this.deviceRepository.create({
      stickerId: dto.stickerId,
      serialNumber: dto.serialNumber,
      deviceTypeId: dto.deviceTypeId,
      status: dto.status,
    });
    if (!row) return null;
    return DeviceCreatedMapper.toResponse(row);
  }

  async getDeviceById(dto: D.GetDeviceByIdDto): Promise<OneDeviceDto | null> {
    const row = await this.deviceRepository.getOne({ id: dto.id });
    if (!row) return null;
    return OneDeviceMapper.toResponse(row);
  }

  async patchDevice(dto: D.PatchDeviceDto): Promise<DevicePatchedDto | null> {
    const row = await this.deviceRepository.patchOne({ id: dto.id }, { status: dto.status });
    if (!row) return null;
    return DevicePatchedMapper.toResponse(row);
  }
}
