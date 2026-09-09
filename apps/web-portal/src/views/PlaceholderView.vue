<script setup lang="ts">
defineProps<{ uxId: string }>();
</script>

<template>
  <section aria-labelledby="placeholder-title" class="placeholder">
    <p class="eyebrow">Day-zero route placeholder</p>
    <h1 id="placeholder-title">{{ uxId }}</h1>
    <p>
      This product surface is intentionally deferred until its contract and domain behavior are
      implemented.
    </p>
  </section>
</template>
