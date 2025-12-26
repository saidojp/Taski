<template lang="pug">
div.dashboard-container
  header
    h1 Team Task Manager
    div.user-info
      span {{ user?.name }}
      button(@click="logout") Logout

  main
    aside.sidebar
      h3 Workspaces
      ul
        li(v-for="org in organizations" :key="org.id" @click="selectOrg(org)" :class="{ active: currentOrganization?.id === org.id }")
          | {{ org.name }}
      
      div.create-org
        input(v-model="newOrgName" placeholder="New Workspace")
        button(@click="createOrg") + Create

    section.content
      div(v-if="currentOrganization")
        h2 {{ currentOrganization.name }}
        StatisticsPanel
        TaskList
      div(v-else)
        p Please select a workspace from the sidebar.
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useOrganizationStore } from '../stores/organization';
import { useRouter } from 'vue-router';
import { storeToRefs } from 'pinia';
import TaskList from '../components/TaskList.vue';
import StatisticsPanel from '../components/StatisticsPanel.vue';

const authStore = useAuthStore();
const orgStore = useOrganizationStore();
const router = useRouter();

const { user } = storeToRefs(authStore);
const { organizations, currentOrganization } = storeToRefs(orgStore);

const newOrgName = ref('');

onMounted(() => {
  orgStore.fetchOrganizations();
  authStore.fetchUser();
});

const selectOrg = (org) => {
  orgStore.selectOrganization(org.id);
};

const createOrg = async () => {
  if (!newOrgName.value) return;
  await orgStore.createOrganization(newOrgName.value);
  newOrgName.value = '';
};

const logout = () => {
  authStore.logout();
  router.push('/login');
};
</script>

<style scoped>
.dashboard-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f8f9fa;
}
header {
  background: white;
  border-bottom: 1px solid #eaeaea;
  padding: 0 30px;
  height: 60px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.02);
  z-index: 10;
}
header h1 {
  font-size: 1.25rem;
  margin: 0;
  color: #333;
}
.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
  font-size: 0.9rem;
  color: #666;
}
.logout-btn {
  background: transparent;
  border: 1px solid #ddd;
  color: #666;
  padding: 5px 12px;
}
.logout-btn:hover {
  background: #f5f5f5;
  color: #333;
}

main {
  display: flex;
  flex: 1;
  overflow: hidden; /* Prevent body scroll */
}

aside.sidebar {
  width: 260px;
  background: white;
  border-right: 1px solid #eaeaea;
  display: flex;
  flex-direction: column;
  padding: 20px 0;
}

aside h3 {
  padding: 0 20px;
  margin-bottom: 10px;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: #999;
}

aside ul {
  list-style: none;
  padding: 0;
  margin: 0;
  flex: 1;
  overflow-y: auto;
}

aside li {
  padding: 10px 20px;
  cursor: pointer;
  border-left: 3px solid transparent;
  color: #555;
  transition: all 0.2s;
}

aside li:hover {
  background: #f9f9f9;
  color: #333;
}

aside li.active {
  background: #e6f7f0;
  color: #42b983;
  border-left-color: #42b983;
  font-weight: 500;
}

.create-org {
  padding: 20px;
  border-top: 1px solid #eaeaea;
  display: flex;
  gap: 8px;
}

.create-org input {
  flex: 1;
  min-width: 0; /* Flex fix */
}

.create-org button {
  padding: 8px 12px;
  background: #42b983;
  color: white;
  border: none;
}
.create-org button:hover {
  background: #3aa876;
}

section.content {
  flex: 1;
  padding: 30px 40px;
  overflow-y: auto;
  background-color: #f8f9fa;
}

.content h2 {
  font-size: 1.8rem;
  color: #2c3e50;
  margin-bottom: 25px;
}

/* Scrollbar styling */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}
::-webkit-scrollbar-track {
  background: transparent;
}
::-webkit-scrollbar-thumb {
  background: #ddd;
  border-radius: 4px;
}
::-webkit-scrollbar-thumb:hover {
  background: #ccc;
}
</style>

