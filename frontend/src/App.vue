<template lang="pug">
div#app-container
  router-view
</template>

<script setup>
</script>

<style>
/* No extra padding here, managed by views */
#app-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
}
</style>
