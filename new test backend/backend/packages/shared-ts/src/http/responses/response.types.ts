import { HttpResponse } from "./response.base";
import { ResponseCode } from "./response.code";

type CommonArgs<T> = Omit<ConstructorParameters<typeof HttpResponse<T>>[0], "status" | "code">;

/* ---------- 200 ---------- */
export class OkResponse<T> extends HttpResponse<T> {
  constructor(args: CommonArgs<T>) {
    super({ status: 200, code: ResponseCode.OK, ...args });
  }
}

/* ---------- 201 ---------- */
export class CreatedResponse<T> extends HttpResponse<T> {
  constructor(args: Omit<CommonArgs<T>, "status" | "code" | "pagination">) {
    super({
      status: 201,
      code: ResponseCode.CREATED,
      ...args,
    });
  }
}

/* ---------- 204 ---------- */
export class NoContentResponse extends HttpResponse<null> {
  constructor(args: Omit<CommonArgs<null>, "status" | "code" | "data" | "pagination">) {
    super({
      status: 204,
      code: ResponseCode.NO_CONTENT,
      ...args,
      data: null,
    });
  }
}
