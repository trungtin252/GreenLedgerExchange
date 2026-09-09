import { describe, expect, it } from 'vitest';
import { routes } from './routes';

describe('route map', () => {
  it('contains all UX-001 through UX-020 placeholder routes', () => {
    const names = new Set(routes.map((route) => route.name));
    for (let number = 1; number <= 20; number += 1) {
      expect(names).toContain(`UX-${String(number).padStart(3, '0')}`);
    }
  });
});
