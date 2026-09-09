import type { RouteRecordRaw } from 'vue-router';

const uxIds = Array.from({ length: 20 }, (_, index) => `UX-${String(index + 1).padStart(3, '0')}`);

export const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('../views/PlaceholderView.vue'),
    props: { uxId: 'GLX-HOME' }
  },
  ...uxIds.map((uxId) => ({
    path: `/${uxId.toLowerCase()}`,
    name: uxId,
    component: () => import('../views/PlaceholderView.vue'),
    props: { uxId }
  }))
];
