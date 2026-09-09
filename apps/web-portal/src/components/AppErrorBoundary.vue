<script setup lang="ts">
import { onErrorCaptured, ref } from 'vue';

const error = ref<Error | null>(null);
onErrorCaptured((captured) => {
  error.value = captured instanceof Error ? captured : new Error(String(captured));
  return false;
});
</script>

<template>
  <section v-if="error" role="alert" class="async-state">
    <h1>Something went wrong</h1>
    <p>{{ error.message }}</p>
  </section>
  <slot v-else />
</template>
