<script setup lang="js">
import { ref, computed, onMounted } from "vue";
import {
  Dialog,
  DialogPanel,
  DialogTitle,
  TransitionRoot,
  TransitionChild,
  Listbox,
  ListboxButton,
  ListboxOptions,
  ListboxOption,
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
} from "@headlessui/vue";
import {
  ChevronUpIcon,
  PencilIcon,
  TrashIcon,
  PlusIcon,
  ChevronUpDownIcon,
  CheckIcon,
} from "@heroicons/vue/24/solid";
import { getAllWithToken, postWithToken, putWithToken, delWithToken } from '../../../lib/fetch-api';

// Reactive state for categories and subcategories (loaded from API)
const categories = ref([]);
const subcategories = ref([]);
const searchQuery = ref("");

// Modal state flags
const isAddCategoryOpen = ref(false);
const isAddSubcategoryOpen = ref(false);
const isEditCategoryOpen = ref(false);
const isEditSubcategoryOpen = ref(false);

// Form fields for adding
const newCategoryName = ref("");
const newSubcategoryName = ref("");
const selectedCategoryForSub = ref(null);

// For editing
const currentCategory = ref(null);
const editedCategoryName = ref("");
const currentSubcategory = ref(null);
const editedSubcategoryName = ref("");

// Load categories and subcategories on mount
onMounted(async () => {
  const catData = await getAllWithToken("categories", null);
  categories.value = catData;
});

// Helper: Filter subcategories belonging to a category
const subcategoriesForCategory = (catId) =>
  subcategories.value.filter((sub) => sub.categoryId === catId);

// Computed: Filter categories by search query
const filteredCategories = computed(() => {
  if (!searchQuery.value.trim()) {
    return categories.value;
  }
  const lowerQuery = searchQuery.value.toLowerCase();
  return categories.value.filter((cat) => {
    const matchCategory = cat.name.toLowerCase().includes(lowerQuery);
    const matchSub = subcategories.value.some(
      (sub) =>
        sub.categoryId === cat.id &&
        sub.name.toLowerCase().includes(lowerQuery)
    );
    return matchCategory || matchSub;
  });
});

// Handlers for adding, editing, and deleting

const handleAddCategory = async () => {
  if (!newCategoryName.value.trim()) {
    alert("Category name cannot be empty.");
    return;
  }
  // Optionally check for duplicates on the client side
  if (
    categories.value.some(
      (cat) =>
        cat.name.toLowerCase() === newCategoryName.value.trim().toLowerCase()
    )
  ) {
    alert("Category name already exists.");
    return;
  }
  const newCat = { name: newCategoryName.value.trim() };
  const created = await postWithToken("categories", newCat);
  categories.value.push(created);
  newCategoryName.value = "";
  isAddCategoryOpen.value = false;
};

const handleAddSubcategory = async () => {
  if (!newSubcategoryName.value.trim()) {
    alert("Subcategory name cannot be empty.");
    return;
  }
  if (!selectedCategoryForSub.value) {
    alert("Please select a category for the subcategory.");
    return;
  }
  // Optionally check for duplicates within the same category
  if (
    subcategories.value.some(
      (sub) =>
        sub.name.toLowerCase() === newSubcategoryName.value.trim().toLowerCase() &&
        sub.categoryId === selectedCategoryForSub.value.id
    )
  ) {
    alert("Subcategory name already exists within the selected category.");
    return;
  }
  const newSub = {
    name: newSubcategoryName.value.trim(),
    categoryId: selectedCategoryForSub.value.id,
  };
  const created = await postWithToken("subcategories", newSub);
  subcategories.value.push(created);
  newSubcategoryName.value = "";
  selectedCategoryForSub.value = null;
  isAddSubcategoryOpen.value = false;
};

const openEditCategory = (cat) => {
  currentCategory.value = cat;
  editedCategoryName.value = cat.name;
  isEditCategoryOpen.value = true;
};

const handleEditCategory = async () => {
  if (!currentCategory.value) return;
  if (!editedCategoryName.value.trim()) {
    alert("Category name cannot be empty.");
    return;
  }
  // Optionally check for duplicates
  if (
    categories.value.some(
      (cat) =>
        cat.name.toLowerCase() === editedCategoryName.value.trim().toLowerCase() &&
        cat.id !== currentCategory.value.id
    )
  ) {
    alert("Another category with the same name exists.");
    return;
  }
  const updated = {
    id: currentCategory.value.id,
    name: editedCategoryName.value.trim(),
  };
  const result = await putWithToken("categories", updated);
  categories.value = categories.value.map((cat) =>
    cat.id === result.id ? result : cat
  );
  currentCategory.value = null;
  editedCategoryName.value = "";
  isEditCategoryOpen.value = false;
};

const openEditSubcategory = (sub) => {
  currentSubcategory.value = sub;
  editedSubcategoryName.value = sub.name;
  isEditSubcategoryOpen.value = true;
};

const handleEditSubcategory = async () => {
  if (!currentSubcategory.value) return;
  if (!editedSubcategoryName.value.trim()) {
    alert("Subcategory name cannot be empty.");
    return;
  }
  // Optionally check for duplicates within same category
  if (
    subcategories.value.some(
      (sub) =>
        sub.name.toLowerCase() === editedSubcategoryName.value.trim().toLowerCase() &&
        sub.categoryId === currentSubcategory.value.categoryId &&
        sub.id !== currentSubcategory.value.id
    )
  ) {
    alert("Another subcategory with the same name exists within the selected category.");
    return;
  }
  const updated = {
    id: currentSubcategory.value.id,
    name: editedSubcategoryName.value.trim(),
    categoryId: currentSubcategory.value.categoryId,
  };
  const result = await putWithToken("subcategories", updated);
  subcategories.value = subcategories.value.map((sub) =>
    sub.id === result.id ? result : sub
  );
  currentSubcategory.value = null;
  editedSubcategoryName.value = "";
  isEditSubcategoryOpen.value = false;
};

const handleDeleteCategory = async (catId) => {
  if (
    !confirm(
      "Are you sure you want to delete this category? All associated subcategories will also be deleted."
    )
  )
    return;
  await delWithToken("categories", catId);
  categories.value = categories.value.filter((cat) => cat.id !== catId);
  subcategories.value = subcategories.value.filter(
    (sub) => sub.categoryId !== catId
  );
};

const handleDeleteSubcategory = async (subId) => {
  if (!confirm("Are you sure you want to delete this subcategory?")) return;
  await delWithToken("subcategories", subId);
  subcategories.value = subcategories.value.filter((sub) => sub.id !== subId);
};
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto bg-blue-50 shadow-md rounded-lg min-h-screen flex flex-col">
    <h1 class="text-4xl font-bold text-blue-700 mb-6 text-center">
      Category Management
    </h1>

    <!-- Search Bar -->
    <div class="mb-6">
      <input
        type="text"
        placeholder="Search categories and subcategories..."
        v-model="searchQuery"
        class="w-full p-3 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
    </div>

    <!-- Action Buttons -->
    <div class="flex space-x-4 mb-6">
      <button
        @click="isAddCategoryOpen = true"
        class="flex items-center px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
      >
        <PlusIcon class="h-5 w-5 mr-2" />
        Add Category
      </button>
      <button
        @click="isAddSubcategoryOpen = true"
        class="flex items-center px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
      >
        <PlusIcon class="h-5 w-5 mr-2" />
        Add Subcategory
      </button>
    </div>

    <!-- Categories List -->
    <div class="flex-1 space-y-4 overflow-auto">
      <template v-if="filteredCategories.length">
        <div
          v-for="category in filteredCategories"
          :key="category.id"
        >
          <Disclosure default-open>
            <template #default="{ open }">
              <div>
                <DisclosureButton class="flex justify-between items-center w-full px-4 py-2 text-sm font-medium text-blue-700 bg-blue-100 rounded-lg hover:bg-blue-200 focus:outline-none focus-visible:ring focus-visible:ring-blue-500 focus-visible:ring-opacity-75">
                  <span>{{ category.name }}</span>
                  <div class="flex space-x-2">
                    <button
                      @click.stop="openEditCategory(category)"
                      class="p-1 bg-yellow-500 text-white rounded hover:bg-yellow-600 transition-colors"
                    >
                      <PencilIcon class="h-4 w-4" />
                    </button>
                    <button
                      @click.stop="handleDeleteCategory(category.id)"
                      class="p-1 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
                    >
                      <TrashIcon class="h-4 w-4" />
                    </button>
                    <ChevronUpIcon
                      :class="open ? 'transform rotate-180' : ''"
                      class="w-5 h-5 text-blue-500"
                    />
                  </div>
                </DisclosureButton>
                <DisclosurePanel class="px-6 pt-4 pb-2 text-sm text-gray-700">
                  <!-- Subcategories List for this Category -->
                  <template v-if="subcategoriesForCategory(category.id).length">
                    <ul class="space-y-2">
                      <li
                        v-for="sub in subcategoriesForCategory(category.id)"
                        :key="sub.id"
                        class="flex justify-between items-center p-2 bg-blue-100 rounded"
                      >
                        <span>{{ sub.name }}</span>
                        <div class="flex space-x-2">
                          <button
                            @click="openEditSubcategory(sub)"
                            class="p-1 bg-yellow-500 text-white rounded hover:bg-yellow-600 transition-colors"
                          >
                            <PencilIcon class="h-4 w-4" />
                          </button>
                          <button
                            @click="handleDeleteSubcategory(sub.id)"
                            class="p-1 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
                          >
                            <TrashIcon class="h-4 w-4" />
                          </button>
                        </div>
                      </li>
                    </ul>
                  </template>
                  <template v-else>
                    <p class="text-gray-400">No subcategories found.</p>
                  </template>
                </DisclosurePanel>
              </div>
            </template>
          </Disclosure>
        </div>
      </template>
      <template v-else>
        <p class="text-gray-500">
          No categories or subcategories found.
        </p>
      </template>
    </div>

    <!-- Add Category Modal -->
    <TransitionRoot :show="isAddCategoryOpen" as="template">
      <Dialog @close="isAddCategoryOpen = false" class="relative z-10">
        <TransitionChild
          as="template"
          enter="ease-out duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="ease-in duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="ease-out duration-300"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="ease-in duration-200"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-blue-50 p-6 text-left shadow-xl transition-all">
                <DialogTitle class="text-lg font-medium leading-6 text-blue-700">
                  Add New Category
                </DialogTitle>
                <div class="mt-4">
                  <input
                    type="text"
                    placeholder="Category Name"
                    v-model="newCategoryName"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div class="mt-6 flex justify-end space-x-4">
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-400"
                    @click="isAddCategoryOpen = false"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-500 px-4 py-2 text-sm font-medium text-white hover:bg-blue-600"
                    @click="handleAddCategory"
                  >
                    Add
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- Add Subcategory Modal -->
    <TransitionRoot :show="isAddSubcategoryOpen" as="template">
      <Dialog @close="isAddSubcategoryOpen = false" class="relative z-10">
        <TransitionChild
          as="template"
          enter="ease-out duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="ease-in duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="ease-out duration-300"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="ease-in duration-200"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-blue-50 p-6 text-left shadow-xl transition-all">
                <DialogTitle class="text-lg font-medium leading-6 text-blue-700">
                  Add New Subcategory
                </DialogTitle>
                <div class="mt-4">
                  <input
                    type="text"
                    placeholder="Subcategory Name"
                    v-model="newSubcategoryName"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div class="mt-4">
                  <Listbox v-model="selectedCategoryForSub">
                    <div class="relative">
                      <ListboxButton class="relative w-full cursor-pointer rounded-lg bg-white py-2 pl-3 pr-10 text-left border border-blue-300 focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <span class="block truncate">
                          {{ selectedCategoryForSub ? selectedCategoryForSub.name : 'Select Category' }}
                        </span>
                        <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
                          <ChevronUpDownIcon class="h-5 w-5 text-blue-400" />
                        </span>
                      </ListboxButton>
                      <TransitionChild
                        as="template"
                        leave="transition ease-in duration-100"
                        leave-from="opacity-100"
                        leave-to="opacity-0"
                      >
                        <ListboxOptions class="absolute mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-blue-500 ring-opacity-5 focus:outline-none">
                          <ListboxOption
                            v-for="cat in categories"
                            :key="cat.id"
                            :value="cat"
                            v-slot="{ active, selected }"
                          >
                            <div
                              :class="`relative cursor-pointer select-none py-2 pl-10 pr-4 ${ active ? 'bg-blue-600 text-white' : 'text-gray-900' }`"
                            >
                              <span :class="`block truncate ${ selected ? 'font-medium' : 'font-normal' }`">
                                {{ cat.name }}
                              </span>
                              <span
                                v-if="selected"
                                :class="`absolute inset-y-0 left-0 flex items-center pl-3 ${ active ? 'text-white' : 'text-blue-600' }`"
                              >
                                <CheckIcon class="h-5 w-5" />
                              </span>
                            </div>
                          </ListboxOption>
                        </ListboxOptions>
                      </TransitionChild>
                    </div>
                  </Listbox>
                </div>
                <div class="mt-6 flex justify-end space-x-4">
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-400"
                    @click="isAddSubcategoryOpen = false"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-500 px-4 py-2 text-sm font-medium text-white hover:bg-blue-600"
                    @click="handleAddSubcategory"
                  >
                    Add
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- Edit Category Modal -->
    <TransitionRoot :show="isEditCategoryOpen" as="template">
      <Dialog @close="isEditCategoryOpen = false" class="relative z-10">
        <TransitionChild
          as="template"
          enter="ease-out duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="ease-in duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="ease-out duration-300"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="ease-in duration-200"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-blue-50 p-6 text-left shadow-xl transition-all">
                <DialogTitle class="text-lg font-medium leading-6 text-blue-700">
                  Edit Category
                </DialogTitle>
                <div class="mt-4">
                  <input
                    type="text"
                    placeholder="Category Name"
                    v-model="editedCategoryName"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div class="mt-6 flex justify-end space-x-4">
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-400"
                    @click="isEditCategoryOpen = false"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-500 px-4 py-2 text-sm font-medium text-white hover:bg-blue-600"
                    @click="handleEditCategory"
                  >
                    Save
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- Edit Subcategory Modal -->
    <TransitionRoot :show="isEditSubcategoryOpen" as="template">
      <Dialog @close="isEditSubcategoryOpen = false" class="relative z-10">
        <TransitionChild
          as="template"
          enter="ease-out duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="ease-in duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>
        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="ease-out duration-300"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="ease-in duration-200"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-blue-50 p-6 text-left shadow-xl transition-all">
                <DialogTitle class="text-lg font-medium leading-6 text-blue-700">
                  Edit Subcategory
                </DialogTitle>
                <div class="mt-4">
                  <input
                    type="text"
                    placeholder="Subcategory Name"
                    v-model="editedSubcategoryName"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div class="mt-6 flex justify-end space-x-4">
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-400"
                    @click="isEditSubcategoryOpen = false"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-500 px-4 py-2 text-sm font-medium text-white hover:bg-blue-600"
                    @click="handleEditSubcategory"
                  >
                    Save
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>


