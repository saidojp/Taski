import { defineStore } from 'pinia';
import api from '../services/api';

export const useTaskStore = defineStore('task', {
  state: () => ({
    tasks: [],
    loading: false,
  }),
  actions: {
    async fetchTasks(orgId) {
      if (!orgId) return;
      this.loading = true;
      try {
        const response = await api.get(`/organizations/${orgId}/tasks`);
        this.tasks = response.data;
      } catch (error) {
        console.error('Failed to fetch tasks', error);
      } finally {
        this.loading = false;
      }
    },
    async createTask(orgId, taskData) {
      try {
        const response = await api.post(`/organizations/${orgId}/tasks`, taskData);
        this.tasks.push(response.data);
      } catch (error) {
        console.error('Failed to create task', error);
        throw error;
      }
    },
    async updateTask(orgId, taskId, updates) {
        try {
            const response = await api.patch(`/organizations/${orgId}/tasks/${taskId}`, updates);
            const index = this.tasks.findIndex(t => t.id === taskId);
            if (index !== -1) {
                this.tasks[index] = response.data;
            }
        } catch (error) {
            console.error('Failed to update task', error);
            throw error;
        }
    },
    async deleteTask(orgId, taskId) {
        try {
            await api.delete(`/organizations/${orgId}/tasks/${taskId}`);
            this.tasks = this.tasks.filter(t => t.id !== taskId);
        } catch (error) {
            console.error('Failed to delete task', error);
            throw error;
        }
    }
  },
});
