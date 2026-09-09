<script setup lang="ts">
withDefaults(
  defineProps<{ state: 'loading' | 'empty' | 'error' | 'forbidden'; message?: string }>(),
  {
    message: undefined
  }
);
</script>

<template>
  <p class="async-state" role="status">{{ message ?? `State: ${state}` }}</p>
</template>
