import { defineStore } from 'pinia';
import api from '../services/api';
import { useOrganizationStore } from './organization';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
    user: null,
  }),
  getters: {
    isAuthenticated: (state) => !!state.token,
  },
  actions: {
    async login(email, password) {
      try {
        const response = await api.post('/auth/login', { email, password });
        this.token = response.data.token;
        this.user = { name: response.data.username };
        localStorage.setItem('token', this.token);
        api.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
        return true;
      } catch (error) {
        console.error('Login failed', error);
        return false;
      }
    },
    async signup(name, email, password, password_confirmation) {
      try {
        const response = await api.post('/users', { name, email, password, password_confirmation });
        this.token = response.data.token;
        this.user = response.data.user;
        localStorage.setItem('token', this.token);
        return true;
      } catch (error) {
        console.error('Signup failed', error);
        throw error;
      }
    },
    logout() {
      this.token = null;
      this.user = null;
      localStorage.removeItem('token');
      localStorage.removeItem('selectedOrgId');
      
      // Clear organization store
      const orgStore = useOrganizationStore();
      orgStore.$reset();
    },
    async fetchUser() {
      if (!this.token) return;
      try {
        const response = await api.get('/users/me');
        this.user = response.data;
      } catch (error) {
        this.logout();
      }
    }
  },
});
