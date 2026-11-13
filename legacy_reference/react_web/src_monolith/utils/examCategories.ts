import { ExamCategory } from '../types';

export interface ExamCategoryGroup extends ExamCategory {
  aliasIds: string[];
  normalizedName: string;
  rawCategories: ExamCategory[];
}

export function cleanExamCategoryName(value?: string | null) {
  return value?.trim().replace(/\s+/g, ' ') || '';
}

export function normalizeExamCategoryName(value?: string | null) {
  return cleanExamCategoryName(value).toLowerCase();
}

export function getExamCategoryRegistryKey(value?: string | null) {
  return encodeURIComponent(normalizeExamCategoryName(value));
}

export function getExamCategoryDocumentId(value?: string | null) {
  const normalizedName = normalizeExamCategoryName(value);

  if (!normalizedName) {
    return '';
  }

  return `exam-cat-${encodeURIComponent(normalizedName)}`;
}

function getExamCategoryCompletenessScore(category: ExamCategory) {
  return [
    typeof category.usersCountOverride === 'number',
    Boolean(category.languages?.trim()),
    category.isPublished !== undefined,
    Boolean(category.createdAt)
  ].filter(Boolean).length;
}

function compareCreatedAt(left?: string, right?: string) {
  if (!left && !right) {
    return 0;
  }

  if (!left) {
    return 1;
  }

  if (!right) {
    return -1;
  }

  return left.localeCompare(right);
}

export function pickPrimaryExamCategory(categories: ExamCategory[]) {
  return [...categories].sort((left, right) => {
    const scoreDiff = getExamCategoryCompletenessScore(right) - getExamCategoryCompletenessScore(left);

    if (scoreDiff !== 0) {
      return scoreDiff;
    }

    const createdAtDiff = compareCreatedAt(left.createdAt, right.createdAt);

    if (createdAtDiff !== 0) {
      return createdAtDiff;
    }

    return left.id.localeCompare(right.id);
  })[0];
}

export function groupExamCategories(categories: ExamCategory[]) {
  const grouped = new Map<string, ExamCategory[]>();

  categories.forEach((category) => {
    const normalizedName = normalizeExamCategoryName(category.name);

    if (!normalizedName) {
      return;
    }

    const existing = grouped.get(normalizedName) || [];
    existing.push(category);
    grouped.set(normalizedName, existing);
  });

  return Array.from(grouped.entries()).map(([normalizedName, groupedCategories]) => {
    const primary = pickPrimaryExamCategory(groupedCategories);
    const fallbackWithUsers = groupedCategories.find((category) => typeof category.usersCountOverride === 'number');
    const fallbackWithLanguages = groupedCategories.find((category) => Boolean(category.languages?.trim()));
    const fallbackPublished = groupedCategories.find((category) => category.isPublished !== undefined);

    return {
      ...primary,
      name: cleanExamCategoryName(primary.name),
      normalizedName,
      aliasIds: groupedCategories.map((category) => category.id),
      rawCategories: groupedCategories,
      usersCountOverride: primary.usersCountOverride ?? fallbackWithUsers?.usersCountOverride,
      languages: primary.languages?.trim() ? primary.languages.trim() : fallbackWithLanguages?.languages?.trim(),
      isPublished: primary.isPublished ?? fallbackPublished?.isPublished,
      iconUrl: primary.iconUrl ?? groupedCategories.find((category) => Boolean(category.iconUrl))?.iconUrl
    } satisfies ExamCategoryGroup;
  });
}

export function findExamCategoryGroupById(categories: ExamCategory[], examCategoryId?: string | null) {
  if (!examCategoryId) {
    return undefined;
  }

  return groupExamCategories(categories).find((group) => group.aliasIds.includes(examCategoryId));
}

export function findExamCategoryGroupByName(categories: ExamCategory[], examCategoryName?: string | null) {
  const normalizedName = normalizeExamCategoryName(examCategoryName);

  if (!normalizedName) {
    return undefined;
  }

  return groupExamCategories(categories).find((group) => group.normalizedName === normalizedName);
}
