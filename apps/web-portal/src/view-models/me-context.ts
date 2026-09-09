import type { MeContext } from '../generated/api';

export type SessionViewModel = {
  displayName: string;
  organizationLabel: string;
  isSandbox: boolean;
};

export function toSessionViewModel(context: MeContext): SessionViewModel {
  return {
    displayName: context.profile.displayName,
    organizationLabel: context.activeOrganizationId ?? 'Not selected',
    isSandbox: context.sandbox
  };
}
