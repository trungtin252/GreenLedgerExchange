<script setup lang="ts">
import AppShell from './components/AppShell.vue';
import AppErrorBoundary from './components/AppErrorBoundary.vue';
</script>

<template>
  <AppErrorBoundary><AppShell /></AppErrorBoundary>
</template>
