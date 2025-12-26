<template lang="pug">
div.stats-panel
  h3 Team Progress
  div(v-if="loading") Loading stats...
  div(v-else-if="stats.length === 0") Run Tasks

  table(v-else)
    thead
      tr
        th User
        th Total
        th Done
        th Rate
    tbody
      tr(v-for="stat in stats" :key="stat.id")
        td {{ stat.user.name }}
        td {{ stat.total_tasks }}
        td {{ stat.completed_tasks }}
        td 
            span.rate-bar
                div.fill(:style="{ width: stat.completion_rate + '%' }")
            | {{ stat.completion_rate }}%
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue';
import { useOrganizationStore } from '../stores/organization';
import { storeToRefs } from 'pinia';

const orgStore = useOrganizationStore();
const { currentOrganization } = storeToRefs(orgStore);

const stats = ref([]);
const loading = ref(false);

const loadStats = async () => {
    if (!currentOrganization.value) return;
    // Don't set loading on poll, only first time potentially or use a separate flag
    // But here we'll just let it update quietly if already loaded
    if (stats.value.length === 0) loading.value = true;
    
    stats.value = await orgStore.fetchStatistics(currentOrganization.value.id);
    loading.value = false;
};

watch(currentOrganization, () => {
    loadStats();
});

// Polling
let pollingInterval = null;

onMounted(() => {
    loadStats(); // Initial load
    pollingInterval = setInterval(() => {
        if (currentOrganization.value) {
            orgStore.fetchStatistics(currentOrganization.value.id).then(res => {
                stats.value = res;
            });
        }
    }, 10000); // 10 seconds
});

onUnmounted(() => {
    if (pollingInterval) clearInterval(pollingInterval);
});
</script>

<style scoped>
.stats-panel {
    background: white;
    padding: 15px;
    border-radius: 8px;
    border: 1px solid #ddd;
    margin-bottom: 20px;
}
table {
    width: 100%;
    border-collapse: collapse;
}
th, td {
    border-bottom: 1px solid #eee;
    padding: 8px;
    text-align: left;
}
.rate-bar {
    display: inline-block;
    width: 50px;
    height: 6px;
    background: #eee;
    margin-right: 5px;
    border-radius: 3px;
    vertical-align: middle;
}
.fill {
    height: 100%;
    background: #42b983;
    border-radius: 3px;
}
</style>
