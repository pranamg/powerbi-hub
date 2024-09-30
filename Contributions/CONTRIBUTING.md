# Contributing to PowerBI-Hub

First off, thank you for considering contributing to the **PowerBI-Hub**! Your contributions help make this project more robust, comprehensive, and valuable to the Power BI community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Your First Code Contribution](#your-first-code-contribution)
  - [Making Changes](#making-changes)
  - [Submitting a Pull Request](#submitting-a-pull-request)
- [Style Guides](#style-guides)
  - [Markdown Style Guide](#markdown-style-guide)
  - [Power BI Best Practices](#power-bi-best-practices)
- [Commit Guidelines](#commit-guidelines)
- [License](#license)

---

## Code of Conduct

Please read and follow our [Code of Conduct](./Contributions/CodeOfConduct.md) to ensure a welcoming and respectful environment for everyone.

## How to Contribute

### 1. Reporting Bugs

If you find a bug in the repository, please [open an issue](https://github.com/pranamg/PowerBI-Hub/issues/new/choose) with the following information:

- **Description:** A clear and concise description of what the bug is.
- **Steps to Reproduce:** Detailed steps to reproduce the behavior.
- **Expected Behavior:** What you expected to happen.
- **Screenshots:** If applicable, add screenshots to help explain your problem.
- **Environment:** Information about your environment (e.g., Power BI version, operating system).

### 2. Suggesting Enhancements

Enhancements and new features are welcome! To suggest an enhancement, please [open an issue](https://github.com/pranamg/PowerBI-Hub/issues/new/choose) and include:

- **Description:** A clear and concise description of the enhancement.
- **Use Case:** Explain how this enhancement will improve the repository or Power BI usage.
- **Possible Implementation:** (Optional) Suggestions on how to implement the enhancement.

### 3. Your First Code Contribution

If you’re new to contributing, consider starting with the following:

- **Documentation:** Improve existing documentation or add new sections.
- **Examples:** Add sample reports, dashboards, or data models.
- **Templates:** Create or enhance Power BI templates for reports or dashboards.

### 4. Making Changes

1. **Fork the Repository:**
   - Click the **Fork** button at the top-right of the repository page.

2. **Clone Your Fork:**
   ```bash
   git clone https://github.com/pranamg/PowerBI-Hub.git

3. **Create a New Branch:**
    ```bash
    git checkout -b feature/your-feature-name

4. **Make Your Changes:**
    - Implement your feature, fix bugs, or improve documentation.

5. **Commit Your Changes:**
    ```bash    
    git add .git commit -m "Add [feature/fix]: Brief description"

    - **Example:** `git commit -m "Add DAX measures for sales analysis"`

6. **Push to Your Fork:**

    ```bash
    git push origin feature/your-feature-name

### 5. Submitting a Pull Request

1. **Navigate to Your Fork:**

    - Go to your forked repository on GitHub.
2. **Compare & Pull Request:**

    - Click the **Compare & pull request** button.
3. **Fill Out the PR Template:**

    - Provide a clear title and description of your changes.
    - Reference any related issues using `#issue-number`.
4. **Submit the Pull Request:**

    - Click **Create pull request**.
5. **Address Feedback:**

    - Be open to feedback and make necessary revisions.

* * *

## Style Guides

### Markdown Style Guide

- **Headings:** Use `#` for main headings, `##` for subheadings, etc.
- **Code Blocks:** Use triple backticks (```) for code snippets.
- **Lists:** Use hyphens (-) or asterisks (\*) for unordered lists and numbers for ordered lists.
- **Links:** Use `[link text](URL)` for hyperlinks.
- **Images:** Use `![alt text](URL)` to embed images.

### Power BI Best Practices

- **Folder Structure:** Follow the repository's established folder structure for consistency.
- **Naming Conventions:** Use clear and descriptive names for files, folders, measures, and columns.
- **Documentation:** Provide clear documentation for any new scripts, measures, or templates added.
- **Optimization:** Ensure that any new DAX measures or Power Query functions are optimized for performance.

* * *

## Commit Guidelines

Adhering to consistent commit messages improves the readability and traceability of changes. Follow these guidelines when committing:

- **Structure:**

    ```markdown
        [Type]: Short description

        Detailed description (optional)

- **Types:**

    - `feat`: A new feature
    - `fix`: A bug fix
    - `docs`: Documentation changes
    - `style`: Code style changes (formatting, missing semi-colons, etc.)
    - `refactor`: Code changes that neither fix a bug nor add a feature
    - `test`: Adding or modifying tests
    - `chore`: Maintenance tasks (build process, dependencies, etc.)
- **Examples:**

    - `feat: Add custom DAX measures for sales analysis`
    - `fix: Correct data source path in Power Query script`
    - `docs: Update README with new folder structure`

* * *

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](https://github.com/pranamg/powerbi-hub/blob/main/LICENSE).

* * *

## Additional Resources

- **[GitHub Flow](https://guides.github.com/introduction/flow/):** Learn about GitHub's workflow.
- **[Power BI Documentation](https://docs.microsoft.com/power-bi/):** Official Power BI documentation.
- **[GitHub Docs: Creating a Pull Request](https://docs.github.com/pull-requests):** Detailed guide on pull requests.

Thank you for contributing to PowerBI-Hub! Your efforts are greatly appreciated and help improve the Power BI ecosystem for everyone.