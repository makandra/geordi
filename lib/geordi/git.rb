module Geordi
  class Git
    class << self
      def local_branch_names
        @local_branch_names ||= begin
          branch_list_string = if Util.testing?
            ENV['GEORDI_TESTING_GIT_BRANCHES'].to_s
          else
            `git branch --format="%(refname:short)"`
          end

          branch_list_string.strip.split("\n")
        end
      end

      def current_branch
        if Util.testing?
          default_branch
        else
          `git rev-parse --abbrev-ref HEAD`.strip
        end
      end

      def staged_changes?
        if Util.testing?
          ENV['GEORDI_TESTING_STAGED_CHANGES'] == 'true'
        else
          statuses = `git status --porcelain`.split("\n")
          statuses.any? { |l| /^[A-Z]/i =~ l }
        end
      end

      def default_branch
        default_branch = if Util.testing?
          ENV['GEORDI_TESTING_DEFAULT_BRANCH']
        else
          head_symref = `git ls-remote --symref origin HEAD`
          head_symref[%r{\Aref: refs/heads/(\S+)\sHEAD}, 1]
        end

        default_branch || 'master'
      end

      def commits_between(source_branch, target_branch)
        return [ENV['GEORDI_TESTING_GIT_COMMIT']] if Util.testing?

        commits = `git --no-pager log --pretty=format:%s origin/#{target_branch}..#{source_branch}`

        commits&.split("\n")
      end
    end
  end
end
