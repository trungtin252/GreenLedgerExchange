import { readFile } from 'node:fs/promises';
import Ajv from 'ajv';
import addFormats from 'ajv-formats';

const example = JSON.parse(await readFile(new URL('../examples/me-context.json', import.meta.url)));
const schema = {
  type: 'object',
  required: ['environment', 'sandbox', 'profile', 'roles', 'capabilities', 'organizations'],
  properties: {
    environment: { type: 'string' },
    sandbox: { type: 'boolean' },
    profile: {
      type: 'object',
      required: ['subject', 'displayName'],
      properties: { subject: { type: 'string' }, displayName: { type: 'string' } }
    },
    roles: { type: 'array', items: { type: 'string' } },
    capabilities: { type: 'object', additionalProperties: { type: 'boolean' } },
    organizations: { type: 'array' },
    activeOrganizationId: { type: ['string', 'null'] }
  }
};
const ajv = new Ajv({ allErrors: true });
addFormats(ajv);
if (!ajv.validate(schema, example)) {
  throw new Error(`Invalid contract example: ${ajv.errorsText()}`);
}
