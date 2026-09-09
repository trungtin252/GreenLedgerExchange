<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router';
</script>

<template>
  <div class="app-shell">
    <header class="app-header">
      <RouterLink class="brand" to="/">GreenLedger Exchange</RouterLink>
      <span class="sandbox-badge">GLX-DEMO sandbox</span>
      <span class="session-placeholder">Organization: not selected · Session: pending</span>
    </header>
    <nav aria-label="Primary navigation">
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/ux-001">Workspace</RouterLink>
      <RouterLink to="/ux-010">Exchange</RouterLink>
    </nav>
    <main id="main-content" tabindex="-1">
      <RouterView v-slot="{ Component }">
        <component :is="Component" />
      </RouterView>
    </main>
  </div>
</template>
