import { defineStore } from 'pinia';
import api from '../services/api';

export const useOrganizationStore = defineStore('organization', {
  state: () => ({
    organizations: [],
    currentOrganization: null,
    organizationUsers: [],
    allUsers: [],
  }),
  actions: {
    async fetchOrganizations() {
      try {
        const response = await api.get('/organizations');
        this.organizations = response.data;
      } catch (error) {
        console.error('Failed to fetch organizations', error);
      }
    },
    async createOrganization(name) {
      try {
        const response = await api.post('/organizations', { name });
        this.organizations.push(response.data);
        return response.data;
      } catch (error) {
        console.error('Failed to create organization', error);
        throw error;
      }
    },
    selectOrganization(orgId) {
      this.currentOrganization = this.organizations.find(o => o.id === orgId) || null;
      if (this.currentOrganization) {
        this.fetchOrganizationUsers(orgId);
        // Persist selection
        localStorage.setItem('selectedOrgId', orgId);
      }
    },
    async fetchOrganizationUsers(orgId) {
      try {
        const response = await api.get(`/organizations/${orgId}/users`);
        this.organizationUsers = response.data;
      } catch (error) {
        console.error('Failed to fetch organization users', error);
        this.organizationUsers = [];
      }
    },
    async fetchStatistics(orgId) {
      try {
        const response = await api.get(`/organizations/${orgId}/statistics`);
        return response.data;
      } catch (error) {
        console.error('Failed to fetch statistics', error);
        return [];
      }
    },
    async fetchAllUsers() {
      try {
        const response = await api.get('/users');
        this.allUsers = response.data;
      } catch (error) {
        console.error('Failed to fetch all users', error);
        this.allUsers = [];
      }
    }
  },
});
