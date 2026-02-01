declare global {
  namespace Express {
    interface Request {
      dto?: any;
      context?: {
        user?: {
          appUserId: string;
        };
      };
    }
  }
}

export {};
