export type ProblemDetails = {
  type: string;
  title: string;
  status: number;
  detail?: string;
  correlationId: string;
};

export function toProblemDetails(value: unknown): ProblemDetails {
  if (typeof value === 'object' && value !== null && 'title' in value && 'status' in value) {
    return value as ProblemDetails;
  }
  return {
    type: 'about:blank',
    title: 'Unexpected error',
    status: 500,
    detail: 'The server returned an unrecognized error response.',
    correlationId: 'unavailable'
  };
}
